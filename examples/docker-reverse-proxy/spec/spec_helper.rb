require 'awspec'
require 'hcl/checker'
#Awsecrets.load(secrets_path: File.expand_path('./secrets.yml', File.dirname(__FILE__)))

module TF
  def parseVars
    file_data = File.read("variables.tf")
    hcl = HCL::Checker.parse(file_data)
    hcl
  end
end
