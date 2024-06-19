const Docker = require('dockerode');
const fs = require('fs');
const path = require('path');

const docker = new Docker();

async function main() {
    try {
        // Check if there is a running container
        let containers = await docker.listContainers({ filters: { status: ['running'] } });
        let container = containers[0]; // Assuming only one running container for simplicity

        if (container) {
            // Copy files to running container
            console.log(`Copying files to container ${container.Id}`);
            await copyFilesToContainer(container.Id);
        } else {
            // Build Docker image and run container
            console.log('No running container found. Building image and running container...');
            await buildAndRunContainer();
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

async function copyFilesToContainer(containerId) {
    const workspacePath = '/var/lib/jenkins/workspace/testcicd';

    // Read contents of workspace directory
    let files = fs.readdirSync(workspacePath);

    // Copy each file/directory to container's /usr/share/nginx/html
    for (let file of files) {
        let localPath = path.join(workspacePath, file);
        await docker.getContainer(containerId).archive({ 
            path: localPath,
            stream: true 
        }).then(function (archiveStream) {
            docker.getContainer(containerId).putArchive(archiveStream, { 
                path: `/usr/share/nginx/html/${file}`
            });
        });
    }

    console.log('Files copied to container successfully.');
}

async function buildAndRunContainer() {
    const dockerfilePath = '/var/lib/jenkins/workspace/testcicd/Dockerfile';
    const imageName = 'server';
    const exposedPort = 9090;

    // Build Docker image
    await docker.buildImage({ context: dockerfilePath, src: ['Dockerfile'] }, { t: imageName });

    // Create and start container
    await docker.createContainer({
        Image: imageName,
        Tty: true,
        ExposedPorts: { '80/tcp': {} },
        HostConfig: {
            PortBindings: { '80/tcp': [{ HostPort: exposedPort.toString() }] }
        }
    }).then(function (container) {
        container.start();
        console.log(`Container running at http://localhost:${exposedPort}`);
    });
}

// Run the main function
main();
