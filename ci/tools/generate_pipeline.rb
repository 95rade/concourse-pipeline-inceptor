#!/usr/bin/ruby
require 'yaml'
require_relative 'inceptor/JobsToListParser'

execution_root_dir="./"

# read pipeline definition file
pipeline_def = YAML.load_file(execution_root_dir+ARGV[0])

# retrieve pipeline YML main template
main_file = execution_root_dir+pipeline_def["pipeline"]["main_template"]
outdata = File.read(main_file)

# define auxiliar variables

all_jobs_output = ""
all_jobs_list = Array.new

all_groups=Array.new
all_groups << { 'name' => 'All', 'jobs' => [] }

# record the last environment id in the loop - to produce trigger job for the next group
last_group_env_id=""

# iterate through all environment groups (e.g. Staging, Production)
pipeline_def["pipeline"]["groups"].each_with_index do |group, index|

  puts "Generating jobs for group "+group["name"]

  group_output = ""
  passed_trigger_statement = ""
  all_group_jobs_list= Array.new


  # determine if this is not the first group and then generate the trigger job between the groups
  if index > 0
    # do the trigger job between groups
    puts "Generating trigger jobs for group "+group["name"]
    # get the trigger template content
    trigger_tmplt = File.read(execution_root_dir+group["trigger_job_template"])
    trigger_name = "trigger_"+group["name"]
    trigger_tmplt = trigger_tmplt.gsub(/{{trigger_name}}/, trigger_name)
    group_output.concat(trigger_tmplt.gsub(/{{env_id}}/, last_group_env_id))
    passed_trigger_statement = "passed: ["+trigger_name+"]"
  end

  # read pipeline template file for the group
  staging_tmplt = File.read(execution_root_dir+group["template"])

  # iterate over all environments withing the group (e.g. all Production environmetns)
  group["environments"].each do |item|
     puts "Generating job for environment "+item["name"]
     # substitutes env name tokens/variables with env id
     tmp_tmplt = staging_tmplt.gsub(/{{env_id}}/, item["name"])
     tmp_tmplt = tmp_tmplt.gsub(/{{stage}}/, item["stage_id"])
     tmp_tmplt = tmp_tmplt.gsub(/{{region}}/, item["region_id"])
     tmp_tmplt = tmp_tmplt.gsub(/{{passed_trigger_statement}}/, passed_trigger_statement)
     group_output.concat(tmp_tmplt)
     last_group_env_id=item["name"]
  end

  # Add list of jobs to the groups entry -> input for the pipeline group definition

  puts "Generating list of jobs for group "+group["name"]

  list_of_jobs = JobsToListParser.getListOfJobs(group_output)

  puts list_of_jobs

  all_jobs_list.concat list_of_jobs
  all_groups <<  { 'name' => group["name"], 'jobs' => list_of_jobs }
  all_jobs_output.concat(group_output)

end

all_groups[0]["jobs"]=all_jobs_list

outdata = outdata.gsub(/{{all_jobs}}/, all_jobs_output)
outdata = outdata.gsub(/{{all_groups}}/, YAML.dump(all_groups).gsub("---\n", ''))
# outdata = outdata.gsub(/{{all_groups}}/, all_staging_jobs_list.inspect)

# outdata = outdata.gsub(/{{.*}}/, "")

File.open(execution_root_dir+"pipeline/pipeline.yml", 'w') do |out|
  out << outdata
end
