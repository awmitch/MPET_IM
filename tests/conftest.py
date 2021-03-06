import pytest
from .test_defs import getNumberOfTests

def pytest_addoption(parser):
  parser.addoption(
      "--modDir",
      action="store",
      default=None,
      help="The directory with the modified test results"
  )
  parser.addoption(
      "--baseDir",
      action="store",
      default=None,
      help="The directory with the base test results"
  )
  parser.addoption(
      "--tolerance",
      action="store",
      default=1e-4,
      help="tolerance for test cases"
  )
  parser.addoption(
      "--slowdown_tolerance",
      action="store",
      default=2,
      help="tolerance for slowdown of test cases"
  )

def pytest_generate_tests(metafunc):
  ntests = getNumberOfTests()
  if "Dirs" in metafunc.fixturenames:
    dir_t = metafunc.config.getoption("modDir")
    dir_b = metafunc.config.getoption("baseDir")
    metafunc.parametrize("Dirs", [ (dir_b + '/test{:03}'.format(i),
        dir_t + '/test{:03}'.format(i))for i in range(1, ntests+1)])
  if "tol" in metafunc.fixturenames:
    metafunc.parametrize("tol", [float(metafunc.config.getoption("tolerance"))])
  if "testDir" in metafunc.fixturenames:
    dir_t = metafunc.config.getoption("modDir")
    metafunc.parametrize("testDir", [dir_t])
  pytest.slowdown_tolerance = float(metafunc.config.getoption("slowdown_tolerance"))
