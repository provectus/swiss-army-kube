require 'spec_helper'
include TF

cluster = TF.parseVars['variable']['cluster_name']['default']
domain  =  TF.parseVars['variable']['domain_name']['default']

describe route53_hosted_zone("#{cluster}.#{domain}.") do
  it { should exist }
  its(:resource_record_set_count) { should eq 3 }
end
