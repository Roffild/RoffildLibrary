# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# https://github.com/Roffild/RoffildLibrary
# ==============================================================================

from distutils.core import setup

Description = "Library for MQL5 (MetaTrader) with Java, Python, Apache Spark, AWS"

setup(
    name="RoffildLibrary",
    version="1.0.0",
    description=Description,
    long_description=Description,
    url="https://roffild.com/",
    author="Roffild",
    author_email="roffild@gmail.com",
    packages=["roffild"],
    license="Apache 2.0",
    keywords="tensorflow mq5 neural-network forex mql mql5",
    project_urls={
        "Documentation": "https://roffild.com/",
        "Source": "https://github.com/Roffild/RoffildLibrary/",
        "Tracker": "https://github.com/Roffild/RoffildLibrary/issues",
    },
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Topic :: Scientific/Engineering",
        "Topic :: Scientific/Engineering :: Mathematics",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "Topic :: Software Development",
        "Topic :: Software Development :: Libraries",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
)
