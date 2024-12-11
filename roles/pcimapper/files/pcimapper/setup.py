from setuptools import setup, find_packages

setup(
    name='pcimapper',
    version='0.0.1',
    packages=find_packages(),
    install_requires=[
        "jc==1.25.3",
        "pydantic==2.5.3",
        "typer==0.9.0",
        "rich==13.9.4",
    ],
    entry_points={
        'console_scripts': [
            'pcimapper = pcimapper.cli:typer_app',
        ],              
    },
    python_requires='>=3.10'
)
