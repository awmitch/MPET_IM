import sys
import os

import numpy as np
import scipy.io as sio

import plot_data

# Strings to be used
RowsStr = "Rows correspond to time points (see generalData.txt).\n"
CCStr = "Columns correspond to cell center positions (see discData.txt)."
FCStr = "Columns correspond to face positions (see discData.txt)."
genDataHdr = ("Time [s], Filling fraction of anode, " +
        "Filling fraction of cathode, " +
        "Voltage [V], Current [C-rate], Current [A/m^2]")

zeroStr = "Zero is at the anode current collector."
dccpStr = "discretization cell center positions [m]. "
discCCbattery = ("Battery " + dccpStr + zeroStr)
discCCanode = ("Anode " + dccpStr + zeroStr)
discCCsep = ("Separator " + dccpStr + zeroStr)
discCCcathode = ("Cathode " + dccpStr + zeroStr)
discFC = ("Battery discretization face positions [m]. " + zeroStr)
particleIndxExpl = """
Particle output files are indexed such that Vol 0 is closest to the
anode current collector for both electrodes.  Indexing within volumes
is such that Part 0 is closest to the "carbon backbone" if simPartCond
was set to true for that electrode. Otherwise it is in arbitrary
order.
"""
particleDiscExpl = """
Particle discretization info follows.  Lengths and number of
discretization points are provided for each simulated particle.
Meshes are made as a linear space between zero and particle length
with the given number of points.  Rows correspond to different
simulation volumes with the first row being closest to the anode
current collector and the last closest to the cathode current
collector.  Columns represent individual particles within each
simulated volume in no particular order.
"""

elytecHdr = ("Electrolyte Concentrations [M]\n" + RowsStr + CCStr)
elytepHdr = ("Electrolyte Electric Potential [V]\n" + RowsStr + CCStr)
elyteiHdr = ("Electrolyte Current Density [A/m^2]\n" + RowsStr + FCStr)
elytediviHdr = ("Electrolyte Divergence of Current Density [A/m^3]\n" +
        RowsStr + CCStr)

seeDiscStr = "See discData.txt for particle indexing information."
partStr = "partTrode{l}vol{j}part{i}."
solffStr = "Solid Filling Fractions"
solTail = ("\n" + RowsStr + CCStr + "\n" + seeDiscStr)
solHdr = (solffStr + solTail)
opStr = ", order parameter "
sol1Hdr = (solffStr + opStr + "1" + solTail)
sol2Hdr = (solffStr + opStr + "2" + solTail)
fnameSolL = "sld{l}Vol{j:03d}Part{i:03d}Conc"
fnameSolR = "Data.txt"
fnameSolBase = (fnameSolL + fnameSolR)
fnameSol1Base = (fnameSolL + "1" + fnameSolR)
fnameSol2Base = (fnameSolL + "2" + fnameSolR)

cbarHdrP1 = ("Average particle filling fractions.\n" + RowsStr)
cbarHdrP2 = """Columns correspond to particles specified by simulated
volume index / particle index within volume.
"""
cbarHdrBase = cbarHdrP1 + cbarHdrP2 + seeDiscStr + "\n"

bulkpHdrP2 = """Columns correspond to this electrode's cell center
positions (see discData.txt).
"""
bulkpHdr = ("Bulk electrode electric potential [V]\n" + RowsStr + bulkpHdrP2)
fnameBulkpBase = "bulkPot{l}Data.txt"

def main(indir, genData=True, discData=True, elyteData=True,
        csldData=True, cbarData=True, bulkpData=True):
    ndD_s, dD_s, ndD_e, dD_e = plot_data.show_data(indir,
            plot_type="params", print_flag=False,
            save_flag=False, data_only=True)
    limtrode = ("c" if ndD_s["z"] < 1 else "a")
    trodes = ndD_s["trodes"]
    CrateCurr = dD_e[limtrode]["cap"] / 3600. # A/m^2
    psd_len_c = dD_s["psd_len"]["c"]
    psd_num_c = ndD_s["psd_num"]["c"]
    Nv_c, Np_c = psd_len_c.shape
    dlm = ","
    def getTrodeStr(l):
        return ("Anode" if l == "a" else "Cathode")
    if "a" in trodes:
        psd_len_a = dD_s["psd_len"]["a"]
        psd_num_a = ndD_s["psd_num"]["a"]
        Nv_a, Np_a = psd_len_a.shape
    tVec, vVec = plot_data.show_data(indir, plot_type="vt",
            print_flag=False, save_flag=False, data_only=True)
    ntimes = len(tVec)

    if genData:
        ffVec_c = plot_data.show_data(indir, plot_type="soc_c",
                print_flag=False, save_flag=False, data_only=True)[1]
        if "a" in trodes:
            ffVec_a = plot_data.show_data(indir, plot_type="soc_a",
                    print_flag=False, save_flag=False,
                    data_only=True)[1]
        else:
            ffVec_a = np.ones(len(tVec))
        currVec = plot_data.show_data(indir, plot_type="curr",
                print_flag=False, save_flag=False, data_only=True)[1]
        genMat = np.zeros((ntimes, 6))
        genMat[:, 0] = tVec
        genMat[:, 1] = ffVec_a
        genMat[:, 2] = ffVec_c
        genMat[:, 3] = vVec
        genMat[:, 4] = currVec
        genMat[:, 5] = currVec * CrateCurr
        np.savetxt(os.path.join(indir, "generalData.txt"),
                genMat, delimiter=dlm, header=genDataHdr)

    if discData:
        cellCentersVec, facesVec = plot_data.show_data(indir,
                plot_type="discData",
                print_flag=False, save_flag=False, data_only=True)
        with open(os.path.join(indir, "discData.txt"), "w") as fo:
            print >> fo, discCCbattery
            print >> fo, ",".join(map(str, cellCentersVec))
            offset = 0
            if "a" in trodes:
                print >> fo
                print >> fo, discCCanode
                print >> fo, ",".join(map(str, cellCentersVec[:Nv_a]))
                offset = Nv_a
            print >> fo
            print >> fo, discCCsep
            print >> fo, ",".join(map(str, cellCentersVec[offset:-Nv_c]))
            print >> fo
            print >> fo, discCCcathode
            print >> fo, ",".join(map(str, cellCentersVec[-Nv_c:]))
            print >> fo
            print >> fo, discFC
            print >> fo, ",".join(map(str, facesVec))
            print >> fo
            print >> fo, particleIndxExpl
            print >> fo, particleDiscExpl
            for l in trodes:
                print >> fo
                Trode = getTrodeStr(l)
                print >> fo, (Trode + " particle sizes [m]")
                for vind in range(ndD_s["Nvol"][l]):
                    print >> fo, ",".join(map(str,
                        dD_s["psd_len"][l][vind, :]))
                print >> fo, ("\n" + Trode + " particle number of discr. points")
                for vind in range(ndD_s["Nvol"][l]):
                    print >> fo, ",".join(map(str,
                        ndD_s["psd_num"][l][vind, :]))

    if elyteData:
        elytecMat = plot_data.show_data(indir,
                plot_type="elytec",
                print_flag=False, save_flag=False, data_only=True)[1]
        elytepMat = plot_data.show_data(indir,
                plot_type="elytep",
                print_flag=False, save_flag=False, data_only=True)[1]
        elyteiMat = plot_data.show_data(indir,
                plot_type="elytei",
                print_flag=False, save_flag=False, data_only=True)[1]
        elytediviMat = plot_data.show_data(indir,
                plot_type="elytedivi",
                print_flag=False, save_flag=False, data_only=True)[1]
        np.savetxt(os.path.join(indir, "elyteConcData.txt"),
                elytecMat, delimiter=dlm, header=elytecHdr)
        np.savetxt(os.path.join(indir, "elytePotData.txt"),
                elytepMat, delimiter=dlm, header=elytepHdr)
        np.savetxt(os.path.join(indir, "elyteCurrDensData.txt"),
                elyteiMat, delimiter=dlm, header=elyteiHdr)
        np.savetxt(os.path.join(indir, "elyteDivCurrDensData.txt"),
                elytediviMat, delimiter=dlm, header=elytediviHdr)

    if csldData:
        ttl_fmt = "% = {perc:2.1f}"
        dataFileName = "output_data.mat"
        dataFile = os.path.join(indir, dataFileName)
        data = sio.loadmat(dataFile)
        type2c = False
        for l in trodes:
            Trode = getTrodeStr(l)
            if ndD_e[l]["type"] in ndD_s["1varTypes"]:
                str_base = partStr + "c"
            elif ndD_e[l]["type"] in ndD_s["2varTypes"]:
                type2c = True
                str1_base = partStr + "c1"
                str2_base = partStr + "c2"
            for i in range(ndD_s["Npart"][l]):
                for j in range(ndD_s["Nvol"][l]):
                    if type2c:
                        sol1 = str1_base.format(l=l, i=i, j=j)
                        sol2 = str2_base.format(l=l, i=i, j=j)
                        datay1 = data[sol1]
                        datay2 = data[sol2]
                        filename1 = fnameSol1Base.format(l=Trode,i=i,j=j)
                        filename2 = fnameSol2Base.format(l=Trode,i=i,j=j)
                        np.savetxt(os.path.join(indir, filename1), datay1,
                                delimiter=dlm, header=sol1Hdr)
                        np.savetxt(os.path.join(indir, filename2), datay2,
                                delimiter=dlm, header=sol2Hdr)
                    else:
                        sol = str_base.format(l=l, i=i, j=j)
                        datay = data[sol]
                        filename = fnameSolBase.format(l=Trode,i=i,j=j)
                        np.savetxt(os.path.join(indir, filename), datay,
                                delimiter=dlm, header=solStr)

    if cbarData:
        cbarDict = plot_data.show_data(indir, plot_type="cbar_full",
                print_flag=False, save_flag=False, data_only=True)
        for l in trodes:
            Trode = getTrodeStr(l)
            fname = "cbar{l}Data.txt".format(l=Trode)
            Nv, Np = ndD_s["Nvol"][l], ndD_s["Npart"][l]
            NpartTot = Nv*Np
            cbarMat = np.zeros((ntimes, NpartTot))
            cbarHdr = cbarHdrBase
            partInd = 0
            for i in range(Nv):
                for j in range(Np):
                    cbarHdr += "{i}/{j},".format(j=j,i=i)
                    cbarMat[:, partInd] = cbarDict[l][:, i, j]
                    partInd += 1
            np.savetxt(os.path.join(indir, fname), cbarMat,
                    delimiter=dlm, header=cbarHdr)

    if bulkpData:
        if "a" in trodes:
            bulkp_aData = plot_data.show_data(indir, plot_type="bulkp_a",
                print_flag=False, save_flag=False, data_only=True)[1]
            fname = fnameBulkpBase.format(l="Anode")
            np.savetxt(os.path.join(indir, fname), bulkp_aData,
                    delimiter=dlm, header=bulkpHdr)
        bulkp_cData = plot_data.show_data(indir, plot_type="bulkp_c",
            print_flag=False, save_flag=False, data_only=True)[1]
        fname = fnameBulkpBase.format(l="Cathode")
        np.savetxt(os.path.join(indir, fname), bulkp_cData,
                delimiter=dlm, header=bulkpHdr)

    return

if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise Exception("Need input directory name")
    indir = sys.argv[1]
    if not os.path.exists(os.path.join(os.getcwd(), indir)):
        raise Exception("Input directory doesn't exist")
    main(indir)