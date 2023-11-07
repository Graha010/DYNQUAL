
# job script template file
JOB_TEMPLATE_FILE=runDynQual_global_on_snellius.sh

# main output folder
MAIN_OUTPUT_FOLDER="/gpfs/work4/0/einf6448/users/edwinoxy/test_dynqual_d02/"

# the variables/files that are the same for the entire period
IRRIGATION_AREA_FILE="/gpfs/work4/0/dynql/input/waterUse/irrigated_areas_ssp3_2000-2050.nc"
DOM_WATER_DEMAND_FILE="/gpfs/work4/0/dynql/input/waterUse/domestic_water_demand_ssp3_2000-2100.nc"
IND_WATER_DEMAND_FILE="/gpfs/work4/0/dynql/input/waterUse/industry_water_demand_ssp3_2000-2100.nc"

# set the variable for the first job - until 2014 (still the historical run)
INITIAL_CONDITION_FOLDER="/gpfs/work4/0/einf6448/users/edwinoxy/data/duncan_initial_conditions/"
DATE_FOR_INITIAL_STATES="2004-12-31"
START_DATE="2005-01-01"
# - for testing
START_DATE="2014-12-29"
END_DATE="2014-12-31"
OUTPUT_FOLDER=${MAIN_OUTPUT_FOLDER}"/2005-2014/"
PRE_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_pr_global_daily_1850_2014_mday-1.nc"
TMP_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_tas_global_daily_1850_2014_C.nc"
ET0_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_pet_global_daily_1979_2014_mday-1.nc"
RAD_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_rsds_global_daily_1850_2014_wm-2.nc"
TMP_ANNUAL_AVG_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/historical/gfdl-esm4_w5e5_historical_tas_global_annAvg_1850_2014_C.nc"
# - submit the historical job
JOBNAME="2005-2014""_DYNQUAL_SSP3_GFDL"
sleep 3
sbatch -J ${JOBNAME} --export OUTPUT_FOLDER=${OUTPUT_FOLDER},START_DATE=${START_DATE},END_DATE=${END_DATE},PRE_FILE=${PRE_FILE},TMP_FILE=${TMP_FILE},ET0_FILE=${ET0_FILE},RAD_FILE=${RAD_FILE},TMP_ANNUAL_AVG_FILE=${TMP_ANNUAL_AVG_FILE},IRRIGATION_AREA_FILE=${IRRIGATION_AREA_FILE},DOM_WATER_DEMAND_FILE=${DOM_WATER_DEMAND_FILE},IND_WATER_DEMAND_FILE=${IND_WATER_DEMAND_FILE},INITIAL_CONDITION_FOLDER=${INITIAL_CONDITION_FOLDER},DATE_FOR_INITIAL_STATES=${DATE_FOR_INITIAL_STATES} ${JOB_TEMPLATE_FILE}


# the variables/files that are the same after the first job (ssp/future run, after 2014)
PRE_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/ssp370/gfdl-esm4_w5e5_ssp370_pr_global_daily_2015_2100_mday-1.nc"
TMP_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/ssp370/gfdl-esm4_w5e5_ssp370_tas_global_daily_2015_2100_C.nc"
ET0_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/ssp370/gfdl-esm4_w5e5_ssp370_pet_global_daily_2015_2100_mday-1.nc"
RAD_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/ssp370/gfdl-esm4_w5e5_ssp370_rsds_global_daily_2015_2100_wm-2.nc"
TMP_ANNUAL_AVG_FILE="/gpfs/work4/0/dynql/input/forcing/GCM/CMIP6/GFDL/ssp370/gfdl-esm4_w5e5_ssp370_tas_global_annAvg_2015_2100_C.nc"


# set the variable for the second job
PREVIOUS_OUTPUT_FOLDER=${OUTPUT_FOLDER}
INITIAL_CONDITION_FOLDER=${PREVIOUS_OUTPUT_FOLDER}"/global/states/"
DATE_FOR_INITIAL_STATES=${END_DATE}
START_DATE="2015-01-01"
END_DATE="2020-12-31"
OUTPUT_FOLDER=${MAIN_OUTPUT_FOLDER}"/2015-2020/"
# - submit the first period job (2015-2020)
PREVJOB=${JOBNAME}
JOBNAME="2015-2020""_DYNQUAL_SSP3_GFDL"
sleep 3
sbatch --dependency=afterany:$(squeue --noheader --format %i --name ${PREVJOB}) -J ${JOBNAME} --export OUTPUT_FOLDER=${OUTPUT_FOLDER},START_DATE=${START_DATE},END_DATE=${END_DATE},PRE_FILE=${PRE_FILE},TMP_FILE=${TMP_FILE},ET0_FILE=${ET0_FILE},RAD_FILE=${RAD_FILE},TMP_ANNUAL_AVG_FILE=${TMP_ANNUAL_AVG_FILE},IRRIGATION_AREA_FILE=${IRRIGATION_AREA_FILE},DOM_WATER_DEMAND_FILE=${DOM_WATER_DEMAND_FILE},IND_WATER_DEMAND_FILE=${IND_WATER_DEMAND_FILE},INITIAL_CONDITION_FOLDER=${INITIAL_CONDITION_FOLDER},DATE_FOR_INITIAL_STATES=${DATE_FOR_INITIAL_STATES} ${JOB_TEMPLATE_FILE}


# set the variable for the remaining jobs and submit them ; we will do this for every 10 year

#~ for STA_YEAR in {2021..2091..10}
for STA_YEAR in {2021..2041..10}
do
PREVIOUS_OUTPUT_FOLDER=${OUTPUT_FOLDER}
INITIAL_CONDITION_FOLDER=${PREVIOUS_OUTPUT_FOLDER}"/global/states/"
DATE_FOR_INITIAL_STATES=${END_DATE}
START_DATE=${STA_YEAR}"-01-01"
END_YEAR=$((x=${STA_YEAR}, y=9, x+y))
END_DATE=${END_YEAR}"-12-31"
OUTPUT_FOLDER=${MAIN_OUTPUT_FOLDER}"/"${STA_YEAR}"-"${END_YEAR}"/"
# - submit the job (20XX-20YY)
PREVJOB=${JOBNAME}
JOBNAME=${STA_YEAR}"-"${END_YEAR}"_DYNQUAL_SSP3_GFDL"
sleep 3
sbatch --dependency=afterany:$(squeue --noheader --format %i --name ${PREVJOB}) -J ${JOBNAME} --export OUTPUT_FOLDER=${OUTPUT_FOLDER},START_DATE=${START_DATE},END_DATE=${END_DATE},PRE_FILE=${PRE_FILE},TMP_FILE=${TMP_FILE},ET0_FILE=${ET0_FILE},RAD_FILE=${RAD_FILE},TMP_ANNUAL_AVG_FILE=${TMP_ANNUAL_AVG_FILE},IRRIGATION_AREA_FILE=${IRRIGATION_AREA_FILE},DOM_WATER_DEMAND_FILE=${DOM_WATER_DEMAND_FILE},IND_WATER_DEMAND_FILE=${IND_WATER_DEMAND_FILE},INITIAL_CONDITION_FOLDER=${INITIAL_CONDITION_FOLDER},DATE_FOR_INITIAL_STATES=${DATE_FOR_INITIAL_STATES} ${JOB_TEMPLATE_FILE}
done


