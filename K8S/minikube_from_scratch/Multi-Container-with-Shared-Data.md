# MultiContainer with Shared Data:
```
Both containers access the same volume at /data. The writer creates content, the reader consumes it. This demonstrates shared storage between containers in the same pod.
What's Really Happening
Writer container:

Continuously writes timestamps to /data/log.txt
When you check its logs with kubectl logs ... -c writer, you see nothing because the echo command redirects output to a file, not to stdout

Reader container:

Runs tail -f which reads from /data/log.txt
Displays what writer wrote
This output appears in reader's logs
```

**example of multi-container-pod.yaml**
```sh

# Specifies the Kubernetes API version to use for this resource
apiVersion: v1

# Defines the type of Kubernetes object we're creating (a Pod)
kind: Pod

# Metadata section - contains identifying information about the Pod
metadata:
  # The unique name for this Pod within its namespace
  name: shared-storage-pod
  # The namespace where this Pod will be created (logical grouping/isolation)
  namespace: development

# Spec section - defines the desired state and configuration of the Pod
spec:
  # List of containers that will run inside this Pod
  containers:
  
  # First container - the "writer"
  - name: writer
    # Docker image to use (busybox is a lightweight Linux with basic utilities)
    image: busybox
    # Override the default command - run the Bourne shell
    command: ["/bin/sh"]
    # Arguments passed to the shell: run an infinite loop that writes timestamps
    # -c: execute the following command string
    # while true: infinite loop
    # echo $(date): print current date/time
    # >> /data/log.txt: append output to log file
    # sleep 5: wait 5 seconds before next iteration
    args: ["-c", "while true; do echo $(date) >> /data/log.txt; sleep 5; done"]
    # Define where to mount volumes inside this container
    volumeMounts:
    # Reference to the volume defined below
    - name: shared-data
      # Path inside the container where the volume will be accessible
      mountPath: /data
  
  # Second container - the "reader"
  - name: reader
    # Same lightweight busybox image
    image: busybox
    # Run the shell
    command: ["/bin/sh"]
    # Arguments: continuously display new lines added to the log file
    # tail -f: follow file output in real-time (like watching a live log)
    # /data/log.txt: the file to monitor (written by the writer container)
    args: ["-c", "tail -f /data/log.txt"]
    # Mount the shared volume in this container too
    volumeMounts:
    # Same volume as the writer (this is how they share data)
    - name: shared-data
      # Same mount path - both containers see the same /data directory
      mountPath: /data
  
  # Define volumes that can be mounted by containers in this Pod
  volumes:
  # The shared volume that both containers will use
  - name: shared-data
    # emptyDir: creates an empty directory when Pod starts
    # {} means use default settings (stored on node's disk)
    # Data is lost when Pod is deleted (not persistent storage)
    # Perfect for temporary data sharing between containers in same Pod
    emptyDir: {}

```
