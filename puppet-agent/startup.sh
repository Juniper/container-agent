#!/bin/sh
# User environment variables like PATH exported here don;t have any affect, as
# they would be overridden by jnet.env file

# Process that stays alive, allows the container to run in background
tail -f /dev/null