import Virtualization

// Passing the path arguments

guard CommandLine.arguments.count == 3 else {
    print("Usage: \(CommandLine.arguments[0]) <kernel-path> <initrd-path>")
    exit(EXIT_FAILURE)
}

let kernelURL = URL(fileURLWithPath: CommandLine.arguments[1])
let initialRamdiskURL = URL(fileURLWithPath: CommandLine.arguments[2])

let configuration = VZVirtualMachineConfiguration()
let maxCpu = VZVirtualMachineConfiguration.maximumAllowedCPUCount
let maxMemory = VZVirtualMachineConfiguration.maximumAllowedMemorySize

configuration.cpuCount = min(4, maxCpu)
configuration.memorySize = min(UInt64(8 * 1024 * 1024 * 1024), maxMemory)
configuration.serialPorts = [ createConsoleConfiguration() ]
configuration.bootLoader = createBootLoader(kernelURL: kernelURL, initialRamdiskURL: initialRamdiskURL )

// validates the configurations

do {
    try configuration.validate()
} catch {
    print("Failed to validate the virtual machine configuration. \(error)")
    exit(EXIT_FAILURE)
}

// function to configure the object to run the VM

func createBootLoader(kernelURL: URL,initialRamdiskURL: URL) -> VZBootLoader {
    let bootLoader = VZLinuxBootLoader(kernelURL: kernelURL)
    bootLoader.initialRamdiskURL = initialRamdiskURL

    let kernelCommandLineArguments = [
        "console=hvc0",
        "rd.break=initqueue"
    ]

    bootLoader.commandLine = kernelCommandLineArguments.joined(separator: " ")

    return bootLoader
}

// Standard in/out configuration for the serial port

func createConsoleConfiguration() -> VZSerialPortConfiguration {
    let consoleConfiguration = VZVirtioConsoleDeviceSerialPortConfiguration()

    let inputFileHandle = FileHandle.standardInput
    let outputFileHandle = FileHandle.standardOutput

    var attributes = termios()
    tcgetattr(inputFileHandle.fileDescriptor, &attributes)
    attributes.c_iflag &= ~tcflag_t(ICRNL)
    attributes.c_iflag &= ~tcflag_t(ICANON | ECHO)
    tcsetattr(inputFileHandle.fileDescriptor, TCSANOW, &attributes)

    let stdioAttachment = VZFileHandleSerialPortAttachment(fileHandleForReading: inputFileHandle, fileHandleForWriting: outputFileHandle)

    consoleConfiguration.attachment = stdioAttachment

    return consoleConfiguration
}

class Delegate: NSObject, VZVirtualMachineDelegate {
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        print("The guest shut down. Exiting.")
        exit(EXIT_SUCCESS)
    }

    func virtualMachine(_ virtualMachine: VZVirtualMachine,
                        didStopWithError error: Error) {
        print("The guest stopped with error: \(error)")
        exit(EXIT_FAILURE)
    }
}

// Instantiate and start the VM

let virtualMachine = VZVirtualMachine(configuration: configuration)

let delegate = Delegate()
virtualMachine.delegate = delegate

virtualMachine.start { (result) in
    if case let .failure(error) = result {
        print("Failed to start the virtual machine \(error)" )
        exit(EXIT_FAILURE)
    }

}

RunLoop.main.run(until: Date.distantFuture)
