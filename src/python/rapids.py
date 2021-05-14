import os
import pyspark.sql.functions as F
import pyspark.sql.types as T
import pytest
from data_gen import *

def runpytest(test_name):
    it_root = os.environ['IT_ROOT']
    pytest_roots = [
        it_root,
        it_root + '/src/main/python'
    ]

    pytest.main(['-k', test_name, '--rootdir'] + pytest_roots)