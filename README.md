# Flux-Node-Tools
Tools to help with Flux Node ops

chmod 755 find_best_server.sh

Example Usage - Valid Arguments are US/EU/AS

```
please chose a server region you would like to test ... (US/EU/AS) US
user selected server US for testing

testing server 5 ...
average download speed for server 5
48440
testing server 6 ...
average download speed for server 6
430662
testing server 7 ...
average download speed for server 7
510509


----------- RESULTS -----------
Best server -- 7
Download speed -- 510509 Kbps
```

## To run the script from the terminal you can use this command

```
bash -i <(curl -s https://raw.githubusercontent.com/JKTUNING/Flux-Node-Tools/main/find_best_server.sh)
```
