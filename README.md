# ASF Serverless Stac (+ DuckDB)

Built from https://github.com/Healy-Hyperspatial/stac-fastapi-duckdb/

## Set up environment

```shell

# Clone repo + submodule
git clone --recursive git@github.com:ua-asf/asf-stac-duckdb.git

# cd into directory
cd asf-stac-duckdb
```

## Get collection data

### Create collection JSON files:

Create `.ndjson` files as shown in https://github.com/ASFHyP3/asf-stac/

`.ndjson` files can be `cat`ted together or kept separate

### Create GeoParquet files

_This will be an excellent candidate to add to Makefile_

```shell
# FIRST, go to the directory that contains sentinel-1-global-coherence.ndjson
cd ..where ever the file is..

# Start Docker
docker run -it \
    -v `pwd -W`:/data/  
    ghcr.io/osgeo/gdal:ubuntu-full-latest 

# Go to /data
cd /data

# Verify the file is there
ls -l sentinel-1-global-coherence.ndjson

# Now run ogr2ogr
ogr2ogr -f Parquet sentinel-1-global-coherence.parquet sentinel-1-global-coherence.ndjson
```

### Upload Parquets

All collection parquet must be uploaded

```shell
s3 cp sentinel-1-global-coherence.parquet s3://stac-bucket/
```

### Refresh collection definitions:

* [`duck-stac/lambda_root/data/stac_collections/glo-30-hand/collection.json`](duck-stac/lambda_root/data/stac_collections/glo-30-hand/collection.json)
* [`duck-stac/lambda_root/data/stac_collections/sentinel-1-global-coherence/collection.json`](duck-stac/lambda_root/data/stac_collections/sentinel-1-global-coherence/collection.json)


## Run as docker container

### Setup

adjust `PARQUET_URLS_JSON` value in submodule Makefile @`stac-fastapi-duckdb/Makefile`

```
PARQUET_URLS_JSON='{"<collection-1>":"s3://<bucket>/<collection-1>.parquet","<collection-2>":"s3://<bucket>/<collection-2>.parquet"}'
```

### Start local server

```shell
# cd into cloned directory
cd asf-stac-duckdb

# cd into stac submodule 
cd stac-fastapi-duckdb

# Start foreground server
make up
```

You can then access the host from http://localhost:8085

## AWS SAM

### Setup 

#### Template Parameters that might need to be adjusted:

* [`StacParquetLocations`](duck-stac/template.yaml#L26) - For customizing 
collection pathing in S3.

* [`StacBucketName`](duck-stac/template.yaml#L38) - bucket name must match
bucket specified in `StacParquetLocations`.

#### Other template parameters:

*  `LambdaMemorySize` - default to 2048
*  `LambdaTimeout` - default to 30 seconds


### Run SAM Local server (Must have [`aws-sam-cli`](https://pypi.org/project/aws-sam-cli/) installed)

```shell
make local
```

You can then access @ http://127.0.0.1:3000/collections

***NOTE***: http://127.0.0.1:3000 and http://127.0.0.1:3000/ may likely 
return `{"message":"Missing Authentication Token"}`. This is something about 
the SAM server not accepting that `Path: /{proxy+}` includes host root.


### Build & Deploy SAM from inside Docker (No `aws-sam-cli` Required)

```shell

# Start the dockerized environment
make shell

# Adjust stack name if desired (default = duck-stac)
export STACK_NAME=duck-stac

# _inside the docker container_ Build the App
make build

# _inside the docker container_ Deploy the app (with Build!)
make deploy 
```
