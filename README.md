# CDP GovCloud Custom Runtimes

Custom FIPS validated ML Runtime images for Cloudera AI (CAI) in GovCloud environments.

## Available Runtimes

### 1. Agent Studio Runtime
**File:** `Dockerfile.AgentStudio-python312`

A comprehensive runtime for building and deploying Cloudera AI Agent Studio applications in GovCloud.

**Features:**
- **Full Agent Studio Platform**: Clones and builds from [cloudera/CAI_STUDIO_AGENT](https://github.com/cloudera/CAI_STUDIO_AGENT)
- **Python 3.12**: Modern Python with `uv` package manager for fast dependency resolution
- **Node.js 22**: Via NVM for Next.js frontend build
- **Next.js Application**: Production-optimized build included
- **Workflow Engine**: Pre-configured virtual environment for agent workflows
- **Multi-stage Build**: Optimized image size by separating build and runtime stages
- **BusyBox Compatible**: Works with minimal base image without traditional package managers

**Build Commands:**
```bash
# Build latest version (main branch)
docker build --pull --rm \
  -f Dockerfile.AgentStudio-python312 \
  -t kevintalbert/cdpgovcustomruntimes:agentstudio-v2.0.0.71 \
  .
```

**Runtime Metadata:**
- **Edition**: Agent Studio for GovCloud
- **Editor**: JupyterLab
- **Kernel**: Agent Studio (Python 3.12 FIPS-Compliant)
- **Version**: 2.0.0.71

**Use in CAI:**
```
kevintalbert/cdpgovcustomruntimes:agentstudio-v2.0.0.71
```

---

### 2. JupyterLab Runtime
**File:** `Dockerfile.JupyterLab-python312`

A lightweight, standard JupyterLab runtime for general-purpose data science and ML workloads in GovCloud.

**Features:**
- **JupyterLab**: Latest JupyterLab interface
- **Python 3.12**: Modern Python runtime
- **Lightweight**: Minimal additional dependencies
- **Fast Build**: Simple, quick-to-build runtime

**Build Command:**
```bash
docker build --pull --rm \
  -f Dockerfile.JupyterLab-python312 \
  -t kevintalbert/cdpgovcustomruntimes:jupyterlab-python312 \
  .
```

**Runtime Metadata:**
- **Edition**: Custom JupyterLab Runtime 2025.07.1-b6
- **Editor**: JupyterLab
- **Kernel**: Python 3

## Base Image

Both runtimes are based on:
```
container-public.repo.cdp.clouderagovt.com/cloudera-public/cloudera/cdsw/ml-runtime-pbj-workbench-python3.12-govcloud:2025.07.1-b6
```

This is the official Cloudera ML Runtime for GovCloud with Python 3.12 support.

## Building the Images

### Prerequisites
- Docker Desktop or Docker Engine
- Access to Cloudera GovCloud registry: `container-public.repo.cdp.clouderagovt.com`


## Runtime Validation

After building, validate the runtime in CAI:

![Runtime Validation](validate-runtime.png)

## FIPS Compliance

### Is This Runtime FIPS Compliant?

**Short Answer**: The runtime **inherits FIPS compliance from the base image**, but you must verify that added components maintain compliance.

**Understanding FIPS in Containers:**

✅ **What IS Inherited:**
- FIPS-enabled OpenSSL from base image
- FIPS-validated kernel crypto (if host is FIPS-enabled)
- System-level crypto libraries
- Base Python built against FIPS OpenSSL

⚠️ **What Can Break FIPS:**
- Python packages with bundled crypto (`cryptography`, `pycryptodome`, etc.)
- Node.js modules with native crypto bindings
- Any compiled extensions linking to non-FIPS crypto
- Static binaries with embedded crypto

### Verifying FIPS Compliance

**Run the verification script inside your container:**

```bash
# Copy verification script into running container
docker cp verify-fips.py <container-id>:/tmp/

# Execute inside container
docker exec -it <container-id> python3 /tmp/verify-fips.py
```

**Or in a CAI Session/Application:**

```python
# Upload verify-fips.py to your project
# Run from terminal or notebook
!python verify-fips.py
```

### FIPS Verification Checklist

The script checks:
1. ✅ **Kernel FIPS Mode** - Is `/proc/sys/crypto/fips_enabled` set to 1?
2. ✅ **OpenSSL FIPS** - Is OpenSSL using FIPS module?
3. ✅ **Python hashlib** - Does Python reject non-FIPS algorithms (MD5, SHA1) for security use?
4. ✅ **OpenSSL Config** - Is FIPS configured in openssl.cnf?
5. ✅ **Python Packages** - Are crypto packages using FIPS-compliant libraries?
6. ✅ **Node.js Crypto** - Can Node.js enable FIPS mode?

### Maintaining FIPS Compliance

**Agent Studio Runtime Considerations:**

1. **uv package manager**: Uses system Python crypto (FIPS-compliant)
2. **Node.js/Next.js**: Uses OpenSSL from base image (should be FIPS)
3. **Python dependencies**: Agent Studio's dependencies should use system crypto

**Best Practices:**
- Always run `verify-fips.py` after building
- Test with your security team before production deployment
- Document FIPS validation results
- Monitor for dependency updates that could affect compliance

**If FIPS Fails:**
```bash
# Check what packages might be problematic
pip list | grep -E 'crypto|ssl|nacl|bcrypt'

# Ensure Python uses FIPS-approved algorithms only
python3 -c "import hashlib; hashlib.md5(b'test', usedforsecurity=True)"
# Should raise: ValueError: [digital envelope routines] unsupported
```

### GovCloud FIPS Requirements

The Cloudera GovCloud base image (`ml-runtime-pbj-workbench-python3.12-govcloud:2025.07.1-b6`) is built with FIPS compliance in mind:
- Red Hat UBI8 FIPS-validated kernel
- FIPS-enabled OpenSSL 1.1.1 or 3.x
- Python built with `--with-openssl-rpath` against FIPS OpenSSL

**Your responsibility**: Ensure added components (Agent Studio, npm packages, Python deps) don't introduce non-FIPS crypto.

## Technical Notes

### Base Image Characteristics
- **OS**: Red Hat UBI8 (minimal)
- **Shell**: BusyBox (limited utilities)
- **Package Manager**: None (no apt, yum, dnf, or microdnf)
- **Pre-installed Tools**: Python 3.12, pip, git, curl, gcc, make
- **Architecture**: linux/amd64





## License

See [LICENSE](LICENSE) for details.

