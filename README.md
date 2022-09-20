# Flux Node Viewer

Flux Node Viewer is a tool to help node ops using a CLI GUI for easy viewing.
- View node benchmarks
- View node status
- View daemon status
- Check if external ports are open
- Verify upnp routing
- Check maintenance window to help with updates and downtime
- Update the node OS
- Verify KDA address
- Restart Node Services
- View Flux Logs

Required packages - checks and installs if missing
- jq
- lsof
- miniupnpc

### Run Flux Node Viewer from the terminal you can use this command

```
bash -i <(curl -s https://raw.githubusercontent.com/JKTUNING/Flux-Node-Tools/main/flux_node_viewer.sh)
```
---
#### View Node Bench marks and error logs
![bench_view](https://user-images.githubusercontent.com/26805518/191158716-6e5dbfd0-74a9-45f8-b772-97437ce033dc.jpg)

---
#### View Node details, maintenance windows and port settings
Showing UPNP enabled and ports open externally (multi-node setup)

![node_view](https://user-images.githubusercontent.com/26805518/191158849-fc70492c-e843-48ed-86f0-329ec5806d49.jpg)

Showing UPNP disabled and ports open externally (single node and port forwarding)

![Flux Viewer Node Ports](https://user-images.githubusercontent.com/26805518/189269343-2efc0d58-5d6b-424a-b815-74e690b5e823.PNG)

---
#### View Node Daemon details and blockchain info
![daemon_view](https://user-images.githubusercontent.com/26805518/191158914-2a17c292-dab4-40c4-bdd6-e557668e666e.jpg)

#### Check External Ports
![check_external_ports](https://user-images.githubusercontent.com/26805518/191159161-c30fed55-361a-4f1d-8ec3-df8917851954.jpg)

#### Mowat's Flux Log Viewer
![Mowats_Log_View](https://user-images.githubusercontent.com/26805518/191159063-05e2ab0c-5fd1-469d-a367-0886fe5ea476.jpg)

#### Available Commands
![commands](https://user-images.githubusercontent.com/26805518/191159246-0c87a455-cd8a-40ed-b00f-91e8462f923d.jpg)

---

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
