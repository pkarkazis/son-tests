"""
 Copyright 2015-2017 Paderborn University

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
"""

# Always prefer setuptools over distutils
from setuptools import setup, find_packages
# To use a consistent encoding
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))

# Get the long description from the README file
with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='sonmanobase',

    # Versions should comply with PEP440.  For a discussion on single-sourcing
    # the version across setup.py and the project code, see
    # https://packaging.python.org/en/latest/single_source_version.html
    version='0.0.1',

    description='SONATA MANO framework base',
    long_description=long_description,

    # The project's main homepage.
    url='https://github.com/sonata-nfv/son-mano-framework/tree/master/son-mano-base',

    # Author details
    author='Manuel Peuster',
    author_email='manuel.peuster@upb.de',

    # Choose your license
    license='Apache 2.0',

    # What does your project relate to?
    keywords='NFV orchestrator',

    packages=find_packages(),
    install_requires=['pika', 'amqpstorm', 'pytest', 'PyYAML', 'requests', 'docker-py'],
    setup_requires=['pytest-runner'],

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # pip to create the appropriate form of executable for the target platform.
    #entry_points={
    #    'console_scripts': [
    #        'sample=sample:main',
    #    ],
    #},
)
