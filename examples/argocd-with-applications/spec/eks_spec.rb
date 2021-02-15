require 'spec_helper'
include TF

cluster = TF.parseVars['variable']['cluster_name']['default']

describe eks(cluster) do
  it { should exist }
  it { should be_active }
  its(:version) { should eq '1.18' }
end
