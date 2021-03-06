import os.path as osp
import scipy.io as sio
import numpy as np
import mpet.io_utils as IO
import tests.test_defs as defs
import errno
import h5py
import pytest

def test_compare(Dirs, tol):
  refDir, testDir = Dirs
  testFailed = False
  newDir = osp.join(testDir, "sim_output")
  refDir = osp.join(refDir, "sim_output")
  newDatah5 = False
  refDatah5 = False
  newDataFile = osp.join(newDir, "output_data.mat")
  if not osp.exists(newDataFile):
    newDataFile = osp.join(newDir, "output_data.hdf5")
    newDatah5 = True
  assert osp.exists(newDataFile), "neither output_data.{mat,hdf5} present"
  refDataFile = osp.join(refDir, "output_data.mat")
  if not osp.exists(refDataFile):
    refDataFile = osp.join(refDir, "output_data.hdf5")
    refDatah5 = True
  assert osp.exists(refDataFile), "neither output_data.{mat,hdf5} present"

  try:
    if newDatah5:
      newData = h5py.File(newDataFile,'r')
    else:
      newData = sio.loadmat(newDataFile)
  except IOError as exception:
    # If it's an error _other than_ the file not being there
    assert exception.errno == errno.ENOENT, "IO error on opening file"
    assert False, "File %s does not exist"%(newDataFile)
    return
        
  if refDatah5:
    refData = h5py.File(refDataFile,'r')
  else:
    refData = sio.loadmat(refDataFile)
  for varKey in (set(refData.keys()) & set(newData.keys())):
    # TODO -- Consider keeping a list of the variables that fail

    # Ignore certain entries not of numerical output
    if varKey[0:2] == "__":
        continue

    #Compute the difference between the solution and the reference
    try:
        varDataNew = newData[varKey]
        varDataRef = refData[varKey]
        diffMat = np.abs(varDataNew - varDataRef)
    except ValueError:
        assert False, "Fail from ValueError"
    except KeyError:
        assert False, "Fail from KeyError"
  
    # #Check absolute and relative error against tol
    assert np.max(diffMat) < tol or \
        np.max(diffMat) < tol*np.max(np.abs(varDataRef)), \
        "Fail from tolerance\nVariable failing: %s\nMax error:\
        %f"%(varKey,np.max(diffMat)) 


def test_cyldifn(testDir, tol):
  _test_analytic(testDir + "/testAnalytCylDifn" , tol, (defs.testAnalytCylDifn, defs.analytCylDifn))

def test_sphdifn(testDir, tol):
  _test_analytic(testDir + "/testAnalytSphDifn" , tol, (defs.testAnalytSphDifn, defs.analytSphDifn))

def _test_analytic(testDir, tol, info):
  newDir = osp.join(testDir, "sim_output")
  newDatah5 = False
  newDataFile = osp.join(newDir, "output_data.mat")
  if not osp.exists(newDataFile):
    newDataFile = osp.join(newDir, "output_data.hdf5")
    newDatah5 = True
  assert osp.exists(newDataFile), "neither output_data.{mat,hdf5} present"

  dD_s, ndD_s = IO.read_dicts(osp.join(newDir, "input_dict_system"))
  tmp = IO.read_dicts(osp.join(newDir, "input_dict_c"))
  dD_e = {}
  ndD_e = {}
  dD_e["c"], ndD_e["c"] = tmp
  try:
    if newDatah5:
      newData = h5py.File(newDataFile,'r')
    else:
      newData = sio.loadmat(newDataFile)
  except IOError as exception:
    # If it's an error _other than_ the file not being there
    assert exception.errno == errno.ENOENT, "IO error on opening file"
    assert False, "File %s does not exist"%(newDataFile)
    return
  t_ref = dD_s["t_ref"]
  L_part = dD_s["psd_len"]["c"][0,0]
  nx_part = ndD_s["psd_num"]["c"][0,0]
  t_refPart = L_part**2 / dD_e["c"]["D"]
  # Skip first time point: analytical solution fails at t=0.
  t0ind = 2
  r0ind = 1
  if newDatah5:
    tvecA = newData["phi_applied_times"][t0ind:] * (t_ref/t_refPart)
  else:
    tvecA = newData["phi_applied_times"][0][t0ind:] * (t_ref/t_refPart)
  cmat = newData["partTrodecvol0part0_c"]
  cmin, cmax = np.min(cmat), np.max(cmat)
  delC = cmax - cmin
  # Skip center mesh point and first time points:
  # analytical solutions have issues with r=0 and t=0
  cmat = cmat[t0ind:,r0ind:]
  nt = len(tvecA)
  # Skip center mesh point: analytical solution as sin(r)/r
  xvecA = np.linspace(0., 1., nx_part)[1:]
  R, T = np.meshgrid(xvecA, tvecA)
  theta = info[1](R, T)
  theta = delC*theta + cmin
  for tind in range(nt):
    cvec = cmat[tind,:]
    thetavec = theta[tind,:]
    assert np.max(np.abs(thetavec - cvec)) < tol,"Fail from tolerance"
