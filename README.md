[![Build Status](https://travis-ci.org/ga4gh/cgtd.svg?branch=master)](https://travis-ci.org/ga4gh/cgtd)

# Cancer Gene Trust Daemon
[The Cancer Gene Trust]
(https://genomicsandhealth.org/work-products-demonstration-projects/cancer-gene-trust)
is a simple, real-time, global network for sharing somatic cancer data and associated clinical information.

The Cancer Gene Trust Daemon (cgtd) stores steward submissions in a distributed,
replicated and decentralized content addressable database.  It provides a basic
HTML interface and RESTful API to add, list and authenticate submissions as well
as the peering relationship between stewards. 

[search.cancergenetrust.org](http://search.cancergenetrust.org) is an example search
engine accross all current stewards that builds a searchable index with network viewer.

Submissions consist of a JSON manifest with a list of fields and files. Fields
typically include de-identified clinical data (i.e. tumor type).  Files
typically consist of somatic variant vcf files and gene expression tsv file.
Manifest's and files are stored and referenced by the [multihash]
(https://github.com/jbenet/multihash) of their content.

Eash steward has a top level JSON index file containing it's dns domain, list of
submissions by multihash and list of peers by address.  Each steward has a
public private key pair which is used to authenticate their submissions. A
steward's address is the multihash of their public key.  A steward's address
resolves to the multihash of the latest version of its index.  Updates to a
steward's index file are signed using their private key.  This provides
authentication and authorization for its contents as well as any other content
referenced via multihash within it including all submissions.

The current underlying implementation leverages [ipfs] (http://ipfs.io) for
storage and replication and ipns for address resolution and public/private key
operations.  The server is implemented using python and [flask]
(http://flask.pocoo.org/)

# Deploying on kubernetes with opencompose or kompose

	Still alpha stage, but in principle it should support a pre-allocated elastic IP.

	opencompose -f opencompose/open-compose.yml
	kubectl -f *.yml

	or

	Works a treat, but does not support ExternalIP, which is needed to link the cgtd service to
	an existing EIP (as in AWS Elastic IP):

	kompose up

# Running locally with docker-compose


	docker-compose up
	docker-compose scale ipfs=3

# Running a production instance on Amazon ECS
	
Following the [official docker amazon ecs-cli instructions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html):

	ecs-cli configure --region ap-southeast-2 --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --cluster cgtd-aus
	ecs-cli up --keypair mba_wwcrc --capability-iam --size 1 --instance-type t2.medium
	ecs-cli compose up

# Running locally with make

Note: The only dependencies for the following is make and docker.

Start the ipfs server and store in ./data/ and generate a default
configuration and public/private key pair in ./data/config:

    make ipfs 

Reset the steward's index to no submissions, no peers, set a domain:

    DOMAIN=lorem.edu make reset

Startup the cgtd container listening on port 80:

    make run

To verify both cgtd and ipfs are working you can query your steward's address:

    curl localhost/v0/address

# Making Submissions

To make a test submission:

    make submit

or via curl:

    docker exec -it cgtd curl -X POST localhost:5000/v0/submissions \
        -F "a_field_name=a_field_value" \
        -F files[]=@tests/ALL/SSM-PAKMVD-09A-01D.vcf

To access the submission:

    curl localhost/v0/submissions/QmZwuc83iD64mvsf484aGcerUHJce1bJtf1y7AAzQDp234

Access control for mutable operations such as adding submissions or peers
is restricted to localhost as a poor mans authentication. As a result we curl
from within the cgtd container above.

To populate a server with a bunch of test data:

    make populate

Finally to see the index for you server including submissions:

    curl localhost/v0/submissions

# Build, Debug and Test Locally

Build a local cgtd docker container:

    make build

Start ipfs, initialize, and start a cgtd container in debug:

    make ipfs
    make reset
    make debug

This runs the cgtd container listening on port 5000 out of the local folder so
you can make changes and it will live reload.

To run tests open another terminal window and:

    make test

# Links
Vancouver GA4GH 2016 Presentation: https://goo.gl/F5Asym  
Overview and White Paper: https://goo.gl/1RyUQ2  
Github: https://github.com/ga4gh/cgtd  
Docker: https://hub.docker.com/r/ga4gh/cgtd/  
Search Example: http://search.cancergenetrust.org  
Slack: cgt-ga4gh.slack.com  
