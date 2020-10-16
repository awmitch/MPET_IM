import numpy, scipy.io
import pickle
import sys
address = str(sys.argv[1])
data=pickle.load( open( "%sinput_dict_system_dD.p"%(address), "rb" )) 
scipy.io.savemat('%sinput_dict_system_dD.mat'%(address), mdict={'sys_inputs': data})
data=pickle.load( open( "%sinput_dict_system_ndD.p"%(address), "rb" )) 
scipy.io.savemat('%sinput_dict_system_ndD.mat'%(address), mdict={'sys_inputs_n': data})
data=pickle.load( open( "%sinput_dict_c_dD.p"%(address), "rb" )) 
scipy.io.savemat('%sinput_dict_c_dD.mat'%(address), mdict={'cath_inputs': data})
