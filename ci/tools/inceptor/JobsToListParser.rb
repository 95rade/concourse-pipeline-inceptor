class JobsToListParser
   def self.getListOfJobs(pjobs_output)
     # reads generated pipeline YML and iterates through its list of jobs
     tmp_group_envs=YAML.load(pjobs_output)
     list_of_jobs = Array.new
     tmp_group_envs.each do |item|
        list_of_jobs << item["name"]
     end
     return list_of_jobs
   end
end
