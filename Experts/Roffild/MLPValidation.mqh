/*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* https://github.com/Roffild/RoffildLibrary
*/
#property copyright "Roffild"
#property link      "https://github.com/Roffild/RoffildLibrary"

#include <Math/Alglib/dataanalysis.mqh>

class CMLPValidation
{
public:
   int Validation;
   bool Random;

   CMLPValidation()
   {
      Validation = 0;
      Random = true;
   }

void MLPKFoldSplit(CMatrixDouble &xy,const int npoints,
                                     const int nclasses, int &foldscount, // hack
                                     const bool stratifiedsplits,int &folds[])
  {
//--- create variables
   int i=0;
   int j=0;
   int k=0;
//--- test parameters
   if(!CAp::Assert(npoints>0,__FUNCTION__+": wrong NPoints!"))
      return;
//--- check
   if(!CAp::Assert(nclasses>1 || nclasses<0,__FUNCTION__+": wrong NClasses!"))
      return;
//--- check
   if(!CAp::Assert(foldscount>=2 && foldscount<=npoints,__FUNCTION__+" wrong FoldsCount!"))
      return;
//--- check
   if(!CAp::Assert(!stratifiedsplits,__FUNCTION__+": stratified splits are not supported!"))
      return;
if (Validation > 0) {
   ArrayResizeAL(folds,npoints);
   ArrayFill(folds, 0, Validation, 0);
   ArrayFill(folds, Validation, npoints - Validation, 1);
   foldscount = 1; // hack
} else {
//--- Folds
   ArrayResizeAL(folds,npoints);
   for(i=0;i<=npoints-1;i++)
      folds[i]=i*foldscount/npoints;
if (Random) {
//--- calculation
   for(i=0;i<=npoints-2;i++)
     {
      j=i+CMath::RandomInteger(npoints-i);
      //--- check
      if(j!=i)
        {
         k=folds[i];
         folds[i]=folds[j];
         folds[j]=k;
        }
     }
}
}
  }

void MLPKFoldCVLBFGS(CMultilayerPerceptron &network,
                                       CMatrixDouble &xy,const int npoints,
                                       const double decay,const int restarts,
                                       const double wstep,const int maxits,
                                       const int foldscount,int &info,
                                       CMLPReport &rep,CMLPCVReport &cvrep)
  {
//--- initialization
   info=0;
//--- function call
   MLPKFoldCVGeneral(network,xy,npoints,decay,restarts,foldscount,false,wstep,maxits,info,rep,cvrep);
  }
void MLPKFoldCVLM(CMultilayerPerceptron &network,
                                    CMatrixDouble &xy,const int npoints,
                                    const double decay,const int restarts,
                                    int foldscount,int &info,CMLPReport &rep,
                                    CMLPCVReport &cvrep)
  {
//--- initialization
   info=0;
//--- function call
   MLPKFoldCVGeneral(network,xy,npoints,decay,restarts,foldscount,true,0.0,0,info,rep,cvrep);
  }

void MLPKFoldCVES(CMultilayerPerceptron &network,
                                    CMatrixDouble &xy,const int npoints,
                                    const double decay,const int restarts,
                                    int foldscount,int &info,CMLPReport &rep,
                                    CMLPCVReport &cvrep)
  {
//--- initialization
   info=0;
//--- function call
   MLPKFoldCVGeneral(network,xy,npoints,decay,restarts,foldscount,false,0.0,0,info,rep,cvrep,true);
  }

void MLPKFoldCVGeneral(CMultilayerPerceptron &n,
                                         CMatrixDouble &xy, int npoints,
                                         const double decay,const int restarts,
                                         int foldscount,const bool lmalgorithm,
                                         const double wstep,const int maxits,
                                         int &info,CMLPReport &rep,
                                         CMLPCVReport &cvrep, const bool early_stopping = false)
  {
//--- create variables
   int i=0;
   int fold=0;
   int j=0;
   int k=0;
   int nin=0;
   int nout=0;
   int rowlen=0;
   int wcount=0;
   int nclasses=0;
   int tssize=0;
   int cvssize=0;
   int relcnt=0;
   int i_=0;
//--- creating arrays
   int    folds[];
   double x[];
   double y[];
//--- create matrix
   CMatrixDouble cvset;
   CMatrixDouble testset;
//--- creating arrays
   CMultilayerPerceptron network;
   CMLPReport            internalrep;
//--- initialization
   info=0;
//--- Read network geometry,test parameters
   CMLPBase::MLPProperties(n,nin,nout,wcount);
//--- check
   if(CMLPBase::MLPIsSoftMax(n))
     {
      nclasses=nout;
      rowlen=nin+1;
     }
   else
     {
      nclasses=-nout;
      rowlen=nin+nout;
     }
//--- check
   if((npoints<=0 || foldscount<2) || foldscount>npoints)
     {
      info=-1;
      return;
     }
//--- function call
   CMLPBase::MLPCopy(n,network);
   CMLPEnsemble netensemble;
   if (early_stopping) {
      CMLPE::MLPECreateFromNetwork(network, 1, netensemble);
   }
//--- K-fold out cross-validation.
//--- First,estimate generalization error
   testset.Resize(npoints,rowlen);
   cvset.Resize(npoints,rowlen);
   ArrayResizeAL(x,nin);
   ArrayResizeAL(y,nout);
//--- function call
   MLPKFoldSplit(xy,npoints,nclasses,foldscount,false,folds);
//--- change values
   cvrep.m_relclserror=0;
   cvrep.m_avgce=0;
   cvrep.m_rmserror=0;
   cvrep.m_avgerror=0;
   cvrep.m_avgrelerror=0;
   rep.m_ngrad=0;
   rep.m_nhess=0;
   rep.m_ncholesky=0;
   relcnt=0;
//--- calculation
   for(fold=0;fold<=foldscount-1;fold++)
     {
      //--- Separate set
      tssize=0;
      cvssize=0;
      for(i=0;i<=npoints-1;i++)
        {
         //--- check
         if(folds[i]==fold)
           {
            for(i_=0;i_<=rowlen-1;i_++)
               testset[tssize].Set(i_,xy[i][i_]);
            tssize=tssize+1;
           }
         else
           {
            for(i_=0;i_<=rowlen-1;i_++)
               cvset[cvssize].Set(i_,xy[i][i_]);
            cvssize=cvssize+1;
           }
        }
      //--- Train on CV training set
      if(lmalgorithm)
         CMLPTrain::MLPTrainLM(network,cvset,cvssize,decay,restarts,info,internalrep);
      else
         if (early_stopping) {
            CMLPE::MLPETrainES(netensemble,cvset,cvssize,decay,restarts,info,internalrep);
         } else {
            CMLPTrain::MLPTrainLBFGS(network,cvset,cvssize,decay,restarts,wstep,maxits,info,internalrep);
         }
      //--- check
      if(info<0)
        {
         //--- change values
         cvrep.m_relclserror=0;
         cvrep.m_avgce=0;
         cvrep.m_rmserror=0;
         cvrep.m_avgerror=0;
         cvrep.m_avgrelerror=0;
         //--- exit the function
         return;
        }
      //--- change values
      rep.m_ngrad=rep.m_ngrad+internalrep.m_ngrad;
      rep.m_nhess=rep.m_nhess+internalrep.m_nhess;
      rep.m_ncholesky=rep.m_ncholesky+internalrep.m_ncholesky;
      //--- Estimate error using CV test set
      if(CMLPBase::MLPIsSoftMax(network))
        {
         //--- classification-only code
         cvrep.m_relclserror=cvrep.m_relclserror+CMLPBase::MLPClsError(network,testset,tssize);
         cvrep.m_avgce=cvrep.m_avgce+CMLPBase::MLPErrorN(network,testset,tssize);
        }
      //--- calculation
      for(i=0;i<=tssize-1;i++)
        {
         for(i_=0;i_<=nin-1;i_++)
            x[i_]=testset[i][i_];
         //--- function call
         CMLPBase::MLPProcess(network,x,y);
         //--- check
         if(CMLPBase::MLPIsSoftMax(network))
           {
            //--- Classification-specific code
            k=(int)MathRound(testset[i][nin]);
            for(j=0;j<=nout-1;j++)
              {
               //--- check
               if(j==k)
                 {
                  //--- change values
                  cvrep.m_rmserror=cvrep.m_rmserror+CMath::Sqr(y[j]-1);
                  cvrep.m_avgerror=cvrep.m_avgerror+MathAbs(y[j]-1);
                  cvrep.m_avgrelerror=cvrep.m_avgrelerror+MathAbs(y[j]-1);
                  relcnt=relcnt+1;
                 }
               else
                 {
                  //--- change values
                  cvrep.m_rmserror=cvrep.m_rmserror+CMath::Sqr(y[j]);
                  cvrep.m_avgerror=cvrep.m_avgerror+MathAbs(y[j]);
                 }
              }
           }
         else
           {
            //--- Regression-specific code
            for(j=0;j<=nout-1;j++)
              {
               cvrep.m_rmserror=cvrep.m_rmserror+CMath::Sqr(y[j]-testset[i][nin+j]);
               cvrep.m_avgerror=cvrep.m_avgerror+MathAbs(y[j]-testset[i][nin+j]);
               //--- check
               if(testset[i][nin+j]!=0.0)
                 {
                  cvrep.m_avgrelerror=cvrep.m_avgrelerror+MathAbs((y[j]-testset[i][nin+j])/testset[i][nin+j]);
                  relcnt=relcnt+1;
                 }
              }
           }
        }
     }
   npoints -= Validation; // hack
//--- check
   if(CMLPBase::MLPIsSoftMax(network))
     {
      cvrep.m_relclserror=cvrep.m_relclserror/npoints;
      cvrep.m_avgce=cvrep.m_avgce/(MathLog(2)*npoints);
     }
//--- change values
   cvrep.m_rmserror=MathSqrt(cvrep.m_rmserror/(npoints*nout));
   cvrep.m_avgerror=cvrep.m_avgerror/(npoints*nout);
   cvrep.m_avgrelerror=cvrep.m_avgrelerror/relcnt;
   info=1;
  }
};
