#!/bin/bash

# we reserve one node of eejit, one contains 96 cores
#SBATCH -N 1

# we use all cores
#SBATCH -n 128

# activate the following if we want to reserve the entire node (which is the case if -n 96)
#SBATCH --exclusive

# the partition name - TODO: Replace this with genoa
#SBATCH -p thin
#~ #SBATCH -p genoa

# job name
#SBATCH -J dynqual

# exporting some variables - IN PROGRESS
#SBATCH --export MAIN_OUTPUT_DIR_INP="",START_DATE_INP="",END_DATE_INP=""


#~ # mail alert at start, end and abortion of execution
#~ #SBATCH --mail-type=ALL
#~ # send mail to this address
#~ #SBATCH --mail-user=XXXX@gmail.com


# please set where you stored DYNQUAL scripts
SCRIPT_FOLDER=$HOME/github/Graha010/DYNQUAL/DynQualModel/

# please 
INI_FILE=$HOME/DYNQUAL/ini/global_run/DynQual_05min_global_gcm.ini
# - Note that I noticed that Edward still use quite old parameter files from PCR-GLOBWB. Shall we update this? If yes, I'll allocate some hours around next week. 

# we activate the correct conda environment on eejit and many other settings
. /home/edwindql/load_all_default.sh


# we go to the folder where the folder script
cd ${SCRIPT_FOLDER}

# global online run with parallelization

OUTPUT_FOLDER="/scratch-shared/edwindql/test/duncan"
START_DATE="2005-01-01"
END_DATE="2014-12-31"
PRE_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_pr_global_daily_1850_2014_mday-1.nc"
TMP_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_tas_global_daily_1850_2014_C.nc"
ET0_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_pet_global_daily_1979_2014_mday-1.nc"
RAD_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_rsds_global_daily_1850_2014_wm-2.nc"
TMP_ANNUAL_AVG_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_tas_global_annAvg_1850_2014_C.nc"
IRRIGATION_AREA_FILE="/gpfs/work4/0/dynql/input/waterUse/irrigated_areas_ssp3_2000-2050.nc"
DOM_WATER_DEMAND_FILE="/gpfs/work4/0/dynql/input/waterUse/domestic_water_demand_ssp3_2000-2100.nc"
IND_WATER_DEMAND_FILE="/gpfs/work4/0/dynql/input/waterUse/industry_water_demand_ssp3_2000-2100.nc"
INITIAL_CONDITION_FOLDER="/scratch-shared/edwindql/duncan_initial_conditions/"
DATE_FOR_INITIAL_STATES="2004-12-31"
python parallel_pcrglobwb_runner_with_argument.py ${INI_FILE} -mod ${OUTPUT_FOLDER} -sd ${START_DATE} -ed ${END_DATE} -misd ${INITIAL_CONDITION_FOLDER} -dfis {DATE_FOR_INITIAL_STATES} -pff ${PRE_FILE} -tff ${TMP_FILE} -rpetff ${ET0_FILE} -radff ${RAD_FILE} -tmp_annavg_ff ${TMP_ANNUAL_AVG_FILE} -irr_fl ${IRRIGATION_AREA_FILE} -dom_fl ${DOM_WATER_DEMAND_FILE} -ind_fl ${IND_WATER_DEMAND_FILE}

# merging the states from the last date
python merge_pcraster_maps.py ${END_DATE} ${OUTPUT_FOLDER} ${OUTPUT_FOLDER}/global/ 8 Global 
