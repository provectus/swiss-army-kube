# v0.0.5

## Add new feature
- Password for RDS generated randomly and stored in SSM
- Google auth for Grafana and EFK
- Add gpu and cpu worker groups and switch worker groups to template
- Added scaling module

## Bug fix
- Fixed resources dependencies to create and destroy without fixes
- Added possibility to destroy route53 zone and RDS
- Templated kfctl.yaml
- Used final snapshot for RDS
- Fixed aws route53 ns record
- Use remote EFS CSI Driver helm chart
- Use nvidia-device-plugin only on GPU nodes
- Assign tags to worker groups for scaling from 0 nodes
- Infer AMI for GPU instances
- Fixed oauth2-proxy module added google auth for oauth2-proxy module added oauth for elk module
- Argo module refactoring 
- Added destroy.sh script to destroy all cluster by running one command added workaround for "Error: RDS Cluster FinalSnapshotIdentifier is required when a final snapshot is required"
