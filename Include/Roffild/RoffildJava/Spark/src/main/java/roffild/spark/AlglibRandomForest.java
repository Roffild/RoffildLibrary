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
package roffild.spark;

import org.apache.spark.ml.classification.DecisionTreeClassificationModel;
import org.apache.spark.ml.classification.RandomForestClassificationModel;
import org.apache.spark.ml.regression.DecisionTreeRegressionModel;
import org.apache.spark.ml.regression.RandomForestRegressionModel;
import org.apache.spark.ml.tree.ContinuousSplit;
import org.apache.spark.ml.tree.InternalNode;
import org.apache.spark.ml.tree.LeafNode;
import org.apache.spark.ml.tree.Node;
import roffild.mqlport.MqlLibrary;
import roffild.mqlport.Pointer;

import java.util.LinkedList;
import java.util.List;

public class AlglibRandomForest
{
   public int nvars;
   public int nclasses;
   public int ntrees;
   public int bufsize;
   public double[] trees;

   public static AlglibRandomForest convert(RandomForestClassificationModel rfmodel)
   {
      AlglibRandomForest alglibRandomForest = new AlglibRandomForest();
      alglibRandomForest.nvars = rfmodel.numFeatures();
      alglibRandomForest.nclasses = rfmodel.numClasses();
      alglibRandomForest.ntrees = rfmodel.getNumTrees();
      LinkedList<Pointer<Double>> forest = new LinkedList<>();
      for (DecisionTreeClassificationModel dfmodel : rfmodel.trees()) {
         LinkedList<Pointer<Double>> tree = new LinkedList<>();
         Pointer<Double> next = new Pointer<>(0.0);
         tree.add(next);
         getTree0(tree, dfmodel.rootNode());
         next.setValue((double)tree.size());
         forest.addAll(tree);
      }
      final int tsize = forest.size();
      alglibRandomForest.bufsize = tsize;
      alglibRandomForest.trees = new double[tsize];
      int index = 0;
      for (Pointer<Double> d : forest) {
         alglibRandomForest.trees[index] = d.value;
         index++;
      }
      return alglibRandomForest;
   }

   public static AlglibRandomForest convert(RandomForestRegressionModel rfmodel)
   {
      AlglibRandomForest alglibRandomForest = new AlglibRandomForest();
      alglibRandomForest.nvars = rfmodel.numFeatures();
      alglibRandomForest.nclasses = 1;
      alglibRandomForest.ntrees = rfmodel.getNumTrees();
      LinkedList<Pointer<Double>> forest = new LinkedList<>();
      for (DecisionTreeRegressionModel dfmodel : rfmodel.trees()) {
         LinkedList<Pointer<Double>> tree = new LinkedList<>();
         Pointer<Double> next = new Pointer<>(0.0);
         tree.add(next);
         getTree0(tree, dfmodel.rootNode());
         next.setValue((double)tree.size());
         forest.addAll(tree);
      }
      final int tsize = forest.size();
      alglibRandomForest.bufsize = tsize;
      alglibRandomForest.trees = new double[tsize];
      int index = 0;
      for (Pointer<Double> d : forest) {
         alglibRandomForest.trees[index] = d.value;
         index++;
      }
      return alglibRandomForest;
   }

   protected static void getTree0(List<Pointer<Double>> tree, Node root)
   {
      if (root instanceof InternalNode) {
         InternalNode node = (InternalNode)root;
         if (node.split() instanceof ContinuousSplit) {
            ContinuousSplit split = (ContinuousSplit)node.split();
            tree.add(new Pointer<>((double)split.featureIndex()));
            // <= vs <
            // https://github.com/apache/spark/blame/master/mllib/src/main/scala/org/apache/spark/ml/tree/Split.scala#L161
            // org.apache.spark.ml.tree.ContinuousSplit.shouldGoLeft(features: Vector) use <=
            // CDForest::DFProcessInternal() use <
            Pointer<Double> th = new Pointer<>(split.threshold() * (double)(1.0D + 1.0E-12D));
            if (th.value == 0.0) {
               th.value = 1.0E-12D;
            }
            tree.add(th);
            Pointer<Double> right = new Pointer<>(99.0);
            tree.add(right);
            getTree0(tree, node.leftChild());
            right.setValue((double)tree.size());
            getTree0(tree, node.rightChild());
         } else {
            System.out.println("Error type!");
         }
      } else {
         LeafNode node = (LeafNode)root;
         tree.add(new Pointer<>(-1.0));
         tree.add(new Pointer<>(node.prediction()));
      }
   }

   public static void save(AlglibRandomForest forest, final String filename)
   {
      MqlLibrary mql = new MqlLibrary();
      final int hfile = mql.FileOpen(filename, mql.FILE_BIN | mql.FILE_WRITE);
      if (hfile != -1) {
         mql.FileWriteInteger(hfile, forest.nvars);
         mql.FileWriteInteger(hfile, forest.nclasses);
         mql.FileWriteInteger(hfile, forest.ntrees);
         mql.FileWriteInteger(hfile, forest.bufsize);
         mql.FileWriteArray(hfile, forest.trees);
         mql.FileClose(hfile);
      }
   }
}
