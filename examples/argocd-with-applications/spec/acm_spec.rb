require 'spec_helper'
include TF

cluster = TF.parseVars['variable']['cluster_name']['default']
domain  =  TF.parseVars['variable']['domain_name']['default']

describe acm("*.#{cluster}.#{domain}") do
  it { should exist }
  it { should be_issued}
end
