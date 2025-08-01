# 🔐 Enigma Machine Simulator

A historically accurate PowerShell implementation of the famous WWII Enigma encryption machine. This simulator recreates the complex mechanical and electrical operations of the original Enigma I machine used by German forces during World War II.

## ✨ Features

- **Historically Accurate**: Implements all 5 original Enigma I rotors (I-V) with correct wirings and notch positions
- **Complete Enigma Components**:
  - **Rotors**: All 5 historical rotors with proper double-stepping mechanism
  - **Reflector**: Standard Reflector B implementation
  - **Plugboard**: Configurable letter pair swapping
  - **Ring Settings**: Full ring position support
- **Authentic Operation**: Rotor advancement occurs before encryption (historically correct timing)
- **Flexible Configuration**: Support for different rotor arrangements and settings
- **Output Formatting**: Results formatted in traditional 5-letter groups with line breaks

## 🚀 Quick Start

```powershell
# Load the script
. .\enigma.ps1

# Basic encryption example
$encrypted = Invoke-EnigmaEncryption -Text "HELLO WORLD"
Write-Host $encrypted

# Decrypt the same message (Enigma is reciprocal)
$decrypted = Invoke-EnigmaEncryption -Text $encrypted
Write-Host $decrypted
```

## 📋 Usage

### Basic Encryption

```powershell
Invoke-EnigmaEncryption -Text "SECRET MESSAGE"
```

### Advanced Configuration

```powershell
# Custom Enigma setup
$config = @{
    RotorConfiguration = @(3, 2, 1)        # Rotors III, II, I (Left-Middle-Right)
    RotorPositions = "ABC"                 # Starting positions
    RingSettings = "XYZ"                   # Ring settings
    PlugboardConnections = "AB CD EF GH"   # Plugboard pairs
}

$encrypted = Invoke-EnigmaEncryption -Text "TOP SECRET" @config
$decrypted = Invoke-EnigmaEncryption -Text $encrypted @config
```

### Historical Configurations

The script includes predefined configurations based on historical usage:

```powershell
# Standard Wehrmacht configuration
[hashtable]$Standard = @{
    RotorConfiguration = @(1, 2, 3) 
    RotorPositions = "AAA"
    RingSettings = "AAA"
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"
}

# Kriegsmarine U-boat configuration (1943)
[hashtable]$Marine1943 = @{
    RotorConfiguration = @(5, 2, 4)        # Rotors V-IV-III
    RotorPositions = "BLA"                 # U-boat call sign
    RingSettings = "AJD"                   # Ring settings
    PlugboardConnections = "AZ BF EQ GT HJ KW MS OY PX UV"
}
```

## ⚙️ Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Text` | String | Message to encrypt/decrypt | Required |
| `RotorConfiguration` | Int[] | Rotor selection (1-5) for Left-Middle-Right positions | `@(3, 2, 1)` |
| `RotorPositions` | String | Starting positions of rotors (A-Z) | `"AAA"` |
| `RingSettings` | String | Ring settings for each rotor (A-Z) | `"AAA"` |
| `PlugboardConnections` | String | Space-separated letter pairs | `""` |

## 🔧 Technical Details

### Rotor Specifications

| Rotor | Wiring | Notch Position |
|-------|--------|----------------|
| I | EKMFLGDQVZNTOWYHXUSPAIBRCJ | Q |
| II | AJDKSIRUXBLHWTMCQGZNPYFVOE | E |
| III | BDFHJLCPRTXVZNYEIWGAKMUSQO | V |
| IV | ESOVPZJAYQUIRHXLNFTGKDCMWB | J |
| V | VZBRGITYUPSDNHLXAWMJQOFECK | Z |

### Double-Stepping Mechanism

The simulator implements the authentic Enigma double-stepping mechanism:
- Right rotor always advances before encryption
- When middle rotor is at notch position, both middle and left rotors advance
- When right rotor is at notch position, middle rotor advances

### Reflector B Wiring

```
YRUHQSLDPXNGOKMIEBFZCWVJAT
```

## 📖 Examples

### Example: Message

```powershell

# Standard
[hashtable]$Standard = @{
    RotorConfiguration = @(1, 2, 3) 
    RotorPositions = "AAA"
    RingSettings = "AAA"
    PlugboardConnections = "AB CD EF GH IJ KL MN OP QR ST"
}

$message = "ENIGMA CHALLENGE"
$encrypted = Invoke-EnigmaEncryption -Text $message @Standard
# Output: FYCLD YEKEA BAXXW

$decrypted = Invoke-EnigmaEncryption -Text $encrypted @Standard
# Output: ENIGM ACHAL LENGE
```

## 🎯 Use Cases

- **Historical Research**: Study WWII cryptography and the Enigma machine
- **Educational**: Learn about rotor-based encryption systems
- **Cryptography Practice**: Understand mechanical encryption principles
- **Security Training**: Demonstrate historical encryption methods
- **Fun Projects**: Create Enigma-style puzzles and challenges

## 🏗️ Architecture

The implementation consists of four main classes:

- **`EnigmaRotor`**: Implements individual rotor mechanics, positions, and ring settings
- **`EnigmaReflector`**: Handles the reflector mechanism that sends signals back through rotors
- **`EnigmaPlugboard`**: Manages the plugboard letter swapping
- **`EnigmaMachine`**: Orchestrates all components and implements the complete encryption process

## 🔍 Validation

The simulator has been tested against known historical Enigma configurations and produces results that match other Enigma simulators, including online tools like [Cryptii's Enigma Machine](https://cryptii.com/pipes/enigma-machine).

## 📚 Historical Context

The Enigma machine was a series of electro-mechanical rotor cipher machines developed and used in the early-to-mid 20th century to protect commercial, diplomatic, and military communication. The German military made extensive use of Enigma during World War II.

## 📄 License

This project is open source and available under the MIT License.

## 🔗 References

- [Enigma Machine - Wikipedia](https://en.wikipedia.org/wiki/Enigma_machine)
- [Technical Details of the Enigma Machine](https://www.cryptomuseum.com/crypto/enigma/)
- [Breaking the Enigma Code](https://www.bletchleypark.org.uk/our-story/enigma)
- [Enigma simulator](https://cryptii.com/pipes/enigma-machine)
- [Enigma challenge](https://bitfabrik.io/blog/index.php?id_post=247)
---

*"Sometimes you don't need a fancy UI, the cloud, or AI. Sometimes all it takes is a machine from almost a century ago, a bit of text, and a touch of madness."*
