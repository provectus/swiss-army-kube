package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestArgoCDApp(t *testing.T) {
	// Run this test in parallel with all the others
	t.Parallel()

	// Unique ID to namespace resources
	// uniqueId := random.UniqueId()
	// Generate a unique name for each VPC so tests running in parallel don't clash
	// vpcName := fmt.Sprintf("test-vpc-%s", uniqueId)
	// Generate a unique key in the S3 bucket for the Terraform state
	// backendS3Key := fmt.Sprintf("/%s/terraform.tfstate", uniqueId)

	terraformOptions := &terraform.Options{
		// Where the Terraform code is located
		TerraformDir: "../argocd",

		// Variables to pass to the Terraform code
		Vars: map[string]interface{}{
			"region":       "eu-north-1",
			"cluster_name": "swiss-army-kube-sub2zero",
			// "argocd":        {
			//                 "branch": "testlab",
			//                 "owner": "sub2zero",
			//         }
		},
		// Vars: map[string]interface{}{
		//         "aws_region":       "us-east-2",
		//         "aws_account_id":   "111122223333", // ID of testing account
		//         "vpc_name":         vpcName,
		//         "cidr_block":       "10.0.0.0/16",
		//         "num_nat_gateways": 1,
		// },

		// Backend configuration to pass to the Terraform code
		// BackendConfig: map[string]interface{}{
		//         "bucket":   "<YOUR-S3-BUCKET>", // bucket in testing account
		//         "region":   "us-east-2", // region of bucket in testing account
		//         "key":      backendS3Key,
		// },
	}

	// Run 'terraform destroy' at the end of the test to clean up
	defer terraform.Destroy(t, terraformOptions)

	// Run 'terraform init' and 'terraform apply' to deploy the module
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "10.10.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnets_cidr_blocks")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"10.10.200.0/24", "10.10.201.0/24"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnets_cidr_blocks")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"10.10.0.0/24", "10.10.1.0/24"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	eksClusterId := terraform.Output(t, terraformOptions, "cluster_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "swiss-army-kube-sub2zero", eksClusterId)
}
