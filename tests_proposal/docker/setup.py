# See https://github.com/pypa/sampleproject

from setuptools import setup, find_packages
import pathlib

here = pathlib.Path(__file__).parent.resolve()

# Get the long description from the README file
long_description = (here / 'README.md').read_text(encoding='utf-8')

setup(
    name='pytest-kube',
    version='0.2.0',
    description='Kubernetes e2e testing',
    long_description=long_description,
    long_description_content_type='text/markdown',
    classifiers=[
        'Development Status :: 1 - Planning',
        'Intended Audience :: Developers',
        'Framework :: Pytest',
        'Topic :: Software Development :: Testing',
        'License :: OSI Approved :: Apache Software License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3 :: Only',
    ],
    keywords='kubernetes, pytest, development',
    packages=find_packages(),
    python_requires='>=3.8, <4',
    install_requires=[
        'pytest>=6,<7',
        'pykube-ng>=20,<21',
        # 'PyYAML>=5,<6',
    ],
    entry_points={
        'pytest11': [
            'pytest-kube = pytest_kube.plugin'
        ]
    },
)