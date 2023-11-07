#!/usr/bin/env python
# -*- coding: utf-8 -*-
#

import os
import sys
import datetime
import glob
import shutil

import pcraster as pcr
from pcraster.framework import DynamicModel
from pcraster.framework import DynamicFramework

from configuration_for_modflow import Configuration
from currTimeStep import ModelTime

try:
    from reporting_for_modflow import Reporting
except:
    pass

try:
    from modflow import ModflowCoupling
except:
    pass

import virtualOS as vos

import logging
logger = logging.getLogger(__name__)

import disclaimer

def modify_ini_file(original_ini_file,
                    system_argument): 

    # created by Edwin H. Sutanudjaja on August 2020 for the Ulysses project
    
    # open and read ini file
    file_ini = open(original_ini_file, "rt")
    file_ini_content = file_ini.read()
    file_ini.close()
    
    # a dictionary containing the system argument codes (e.g. -xyz, -abc) and their variable names (e.g. DEFGH and OPQRSTU)
    ini_variables = {}
    ini_variables["-mod"]           = "OUTPUT_FOLDER"
    ini_variables["-sd"]            = "START_DATE"
    ini_variables["-ed"]            = "END_DATE"
    ini_variables["-misd"]          = "INITIAL_CONDITION_FOLDER"
    ini_variables["-dfis"]          = "DATE_FOR_INITIAL_STATES"
    ini_variables["-pff"]           = "PRE_FILE"
    ini_variables["-tff"]           = "TMP_FILE"
    ini_variables["-rpetff"]        = "ET0_FILE"
    ini_variables["-radff"]         = "RAD_FILE"
    ini_variables["-tmp_annavg_ff"] = "TMP_ANNUAL_AVG_FILE"
    ini_variables["-irr_fl"]        = "IRRIGATION_AREA_FILE"
    ini_variables["-dom_fl"]        = "DOM_WATER_DEMAND_FILE"
    ini_variables["-ind_fl"]        = "IND_WATER_DEMAND_FILE"
    
    for var in ini_variables.keys:
         
         assigned_string  = system_argument[system_argument.index(var) + 1]

         # for the output directory
         if var == "-mod":
			 
             output_dir = assigned_string

             # parallel option
             this_run_is_part_of_a_set_of_parallel_run = False    
             if system_argument[2] == "parallel" or system_argument[2] == "debug_parallel": this_run_is_part_of_a_set_of_parallel_run = True
             
             # for a parallel run (usually 5 arcmin), we assign the following based on the clone number/code:
             if this_run_is_part_of_a_set_of_parallel_run:
                 # set the output directory for every clone
                 output_dir = output_dir + "/M" + clone_code + "/"

         file_ini_content = file_ini_content.replace(ini_variables[var], assigned_string)
         msg = "The string " + str(ini_variables[var]) + " in the given configuration file is replaced with the one given after the system argument " +  str(var) + ": "  + assigned_string + "."

         print(msg)


    # folder for saving original and modified ini files
    folder_for_ini_files = os.path.join(output_dir, "ini_files")
    # - create folder
    if os.path.exists(folder_for_ini_files): shutil.rmtree(folder_for_ini_files)
    os.makedirs(folder_for_ini_files)
    
    # save/copy the original ini file
    shutil.copy(original_ini_file, os.path.join(folder_for_ini_files, os.path.basename(original_ini_file) + ".original"))

    # save the new ini file
    new_ini_file_name = os.path.join(folder_for_ini_files, os.path.basename(original_ini_file) + ".modified_and_used")
    new_ini_file = open(new_ini_file_name, "w")
    new_ini_file.write(file_ini_content)
    new_ini_file.close()
            
    return new_ini_file_name
