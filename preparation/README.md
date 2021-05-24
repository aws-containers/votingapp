The `prepare.sh` script creates the DDB table and create an IAM role with a policy to access it. You can associate this role to an Amazon App Runner service (the role is federated with Amazon App Runner).

The script assign a DDB table name and IAM role name in two variables at the beginning. You can change them if you wish.
