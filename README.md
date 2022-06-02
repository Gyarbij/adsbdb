<p align="center">
 <img src='./.github/logo.svg' width='125px'/>
</p>

<p align="center">
 <h1 align="center"><a href='https://api.adsbdb.com' target='_blank' rel='noopener noreferrer'>api.adsbdb.com</a></h1>
</p>

<p align="center">
	public aircraft & flightroute api
</p>

<p align="center">
	Built in <a href='https://www.rust-lang.org/' target='_blank' rel='noopener noreferrer'>Rust</a>
	for <a href='https://www.docker.com/' target='_blank' rel='noopener noreferrer'>Docker</a>,
	using <a href='https://www.postgresql.org/' target='_blank' rel='noopener noreferrer'>PostgreSQL</a>
	& <a href='https://www.redis.io/' target='_blank' rel='noopener noreferrer'>Redis</a> 
	<br>
	<sub> See typescript branch for original typescript version</sub>
</p>


<!-- <p align="center">
  This flight route data is the work of David Taylor, Edinburgh and Jim
Mason, Glasgow, and may not be copied, published, or incorporated into other
databases without the explicit permission of David J Taylor, Edinburgh
</p> -->


## Routes

```https://api.adsbdb.com/v[semver.major]/aircraft/[MODE_S]```
```json
{
	"response":{
		"aircraft":{
			"type": string,
			"icao_type": string,
			"manufacturer": string,
			"mode_s": string,
			"n_number": string,
			"registered_owner_country_iso_name": string,
			"registered_owner_country_name": string,
			"registered_owner_operator_flag_code": string,
			"registered_owner": string,
			"url_photo":string || null,
			"url_photo_thumbnail":string || null
		}
	}
}

```

Unknown aircraft return status 404 with
```json
{ "response": "unknown aircraft"}
```
---

Convert from MODE-S string to N-Number string
```https://api.adsbdb.com/v[semver.major]/mode-s/[MODE_S]```
```json
{
	"response": string
}

```
---

Convert from N-Number string to Mode_S string
```https://api.adsbdb.com/v[semver.major]/n-number/[N-NUMBER]```
```json
{
	"response": string
}

```
---

```https://api.adsbdb.com/v[semver.major]/callsign/[CALLSIGN]```
```json
{
	"response": {
		"flightroute":{
			"callsign": string,
			"origin_airport_country_iso_name": string,
			"origin_airport_country_name": string,
			"origin_airport_elevation": number,
			"origin_airport_iata_code": string,
			"origin_airport_icao_code": string,
			"origin_airport_latitude": number,
			"origin_airport_longitude": number,
			"origin_airport_municipality": string,
			"origin_airport_name": string,

			"destination_airport_country_iso_name": string,
			"destination_airport_country_name": string,
			"destination_airport_elevation": number,
			"destination_airport_iata_code": string,
			"destination_airport_icao_code": string,
			"destination_airport_latitude": number,
			"destination_airport_longitude": number,
			"destination_airport_municipality": string,
			"destination_airport_name": string
		}
	}
}
```

For a small number of flightroutes, midpoints are also included
```json
{
	"midpoint_airport_country_iso_name": string,
	"midpoint_airport_country_name": string,
	"midpoint_airport_elevation": number,
	"midpoint_airport_iata_code": string,
	"midpoint_airport_icao_code": string,
	"midpoint_airport_latitude": number,
	"midpoint_airport_longitude": number,
	"midpoint_airport_municipality": string,
	"midpoint_airport_name": string
}
```

Unknown callsign return status 404 with
```json
{ "response": "unknown callsign"}
```
---

```https://api.adsbdb.com/v[semver.major]/aircraft/[MODE_S]?callsign=[CALLSIGN]``` 

```json
{
	"response": {
		"aircraft":{
			"type": string,
			"icao_type": string,
			"manufacturer": string,
			"mode_s": string,
			"n_number": string,
			"registered_owner_country_iso_name": string,
			"registered_owner_country_name": string,
			"registered_owner_operator_flag_code": string,
			"registered_owner": string,
			"url_photo":string || null,
			"url_photo_thumbnail":string || null
		},
		"flightroute":{
			"callsign": string,
			"origin_airport_country_iso_name": string,
			"origin_airport_country_name": string,
			"origin_airport_elevation": number,
			"origin_airport_iata_code": string,
			"origin_airport_icao_code": string,
			"origin_airport_latitude": number,
			"origin_airport_longitude": number,
			"origin_airport_municipality": string,
			"origin_airport_name": string,
			"destination_airport_country_iso_name": string,
			"destination_airport_country_name": string,
			"destination_airport_elevation": number,
			"destination_airport_iata_code": string,
			"destination_airport_icao_code": string,
			"destination_airport_latitude": number,
			"destination_airport_longitude": number,
			"destination_airport_municipality": string,
			"destination_airport_name": string
		}
	}
}
```

If an unknown callsign is provided as a query param, but the aircraft is known, response will be status 200 with just aircraft

---

## Download

See <a href="https://github.com/mrjackwills/adsbdb/releases" target='_blank' rel='noopener noreferrer'>releases</a>

download (x86_64_musl one liner)

```bash
wget https://www.github.com/mrjackwills/adsbdb/releases/latest/download/adsbdb_linux_x86_64_musl.tar.gz &&
tar xzvf adsbdb_linux_x86_64_musl.tar.gz adsbdb
```

### Run

Operate docker compose containers via

```bash
./run.sh
```

## Tests

Requires postgres & redis to both be operational and seeded with valid data

```bash
# Watch
cargo watch -q -c -w src/ -x 'test  -- --test-threads=1 --nocapture'

# Run all 
cargo test -- --test-threads=1 --nocapture
```