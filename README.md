# Flux Node Viewer

Flux Node Viewer is a tool to view your node's benchmarks, view node status, view daemon status and update the node OS.

### Run Flux Node Viewer from the terminal you can use this command

```
bash -i <(curl -s https://raw.githubusercontent.com/JKTUNING/Flux-Node-Tools/main/flux_node_viewer.sh)
```
#### View Node Bench marks and error logs
![Flux Viewer Bench](https://user-images.githubusercontent.com/26805518/187343437-0a203bd0-5a34-4f27-a986-93aa4b4380bc.PNG)

#### View Node details and maintenance windows
![Flux Viewer Node](https://user-images.githubusercontent.com/26805518/188040555-59057a4c-0cd5-4d3f-b64f-794053bd744b.PNG)

#### View Node Daemon details and blockchain info
![Flux Viewer Daemon](https://user-images.githubusercontent.com/26805518/187343491-06e3c8b1-d0fc-4104-9398-38b90074a784.PNG)


# Find Best Server Script

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
