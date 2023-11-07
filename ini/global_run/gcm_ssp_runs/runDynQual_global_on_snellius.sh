#!/bin/bash

# we reserve one node of eejit, one contains 96 cores
#SBATCH -N 1

# the partition name - We use genoa node (maximum number of cores: 192, RAM: 336 GB)
#SBATCH -p genoa

# we use 64 cores (1/3 of genoa node, maximum memory: 112 GB)
#SBATCH -n 64

#~ #SBATCH -t 119:59:00
#~ ## this is the time, maximum 120:00:00 hours

#SBATCH -t 59:00
## for testing, set it shorter than 1 hour

# job name
#SBATCH -J dynqual

# exporting some variables - IN PROGRESS
#SBATCH --export OUTPUT_FOLDER=${OUTPUT_FOLDER},START_DATE=${START_DATE},END_DATE=${END_DATE},PRE_FILE=${PRE_FILE},TMP_FILE=${TMP_FILE},ET0_FILE=${ET0_FILE},RAD_FILE=${RAD_FILE},TMP_ANNUAL_AVG_FILE=${TMP_ANNUAL_AVG_FILE},IRRIGATION_AREA_FILE=${IRRIGATION_AREA_FILE},DOM_WATER_DEMAND_FILE=${DOM_WATER_DEMAND_FILE},IND_WATER_DEMAND_FILE=${IND_WATER_DEMAND_FILE},INITIAL_CONDITION_FOLDER=${INITIAL_CONDITION_FOLDER},INITIAL_STATES=${INITIAL_STATES}


#~ # mail alert at start, end and abortion of execution
#~ #SBATCH --mail-type=ALL
#~ # send mail to this address
#~ #SBATCH --mail-user=XXXX@gmail.com


# please set where you stored DYNQUAL scripts
SCRIPT_FOLDER=/home/edwinoxy/github/Graha010/DYNQUAL/DynQualModel/

# configuration (.ini) file
INI_FILE=/home/edwinoxy/github/Graha010/DYNQUAL/ini/global_run/gcm_ssp_runs/DynQual_05min_global_gcm.ini


# we activate the correct conda environment on eejit and many other settings
# load miniconda
# - using 2022 modules (suitable for genoa nodes)
module load 2022
module load Miniconda3/4.12.0
# - abandon any existing PYTHONPATH (recommended, if you want to use miniconda or anaconda)
unset PYTHONPATH
# - activate conda env for pcrglobwb
source activate /home/hydrowld/.conda/envs/pcrglobwb_python3_2023-10-31


# we go to the folder where the folder script
cd ${SCRIPT_FOLDER}


# global online run with parallelization

#~ # - old method - DO NOT USE IT!
#~ python parallel_pcrglobwb_runner_with_argument.py ${INI_FILE} -mod ${OUTPUT_FOLDER} -sd ${START_DATE} -ed ${END_DATE} -misd ${INITIAL_CONDITION_FOLDER} -dfis ${DATE_FOR_INITIAL_STATES} -pff ${PRE_FILE} -tff ${TMP_FILE} -rpetff ${ET0_FILE} -radff ${RAD_FILE} -tmp_annavg_ff ${TMP_ANNUAL_AVG_FILE} -irr_fl ${IRRIGATION_AREA_FILE} -dom_fl ${DOM_WATER_DEMAND_FILE} -ind_fl ${IND_WATER_DEMAND_FILE}

# - for testing
for i in {2..4}
#~ # - loop through all clones
#~ for i in {1..53}

do

CLONE_CODE=${i}
python deterministic_runner_new.py ${INI_FILE} debug_parallel ${CLONE_CODE} -mod ${OUTPUT_FOLDER} -sd ${START_DATE} -ed ${END_DATE} -misd ${INITIAL_CONDITION_FOLDER} -dfis ${DATE_FOR_INITIAL_STATES} -pff ${PRE_FILE} -tff ${TMP_FILE} -rpetff ${ET0_FILE} -radff ${RAD_FILE} -tmp_annavg_ff ${TMP_ANNUAL_AVG_FILE} -irr_fl ${IRRIGATION_AREA_FILE} -dom_fl ${DOM_WATER_DEMAND_FILE} -ind_fl ${IND_WATER_DEMAND_FILE} &

done

# - wait until all clone runs are finished
wait

# merging the states from the last date
python merge_pcraster_maps.py ${END_DATE} ${OUTPUT_FOLDER} ${OUTPUT_FOLDER}/global/ 8 Global 
