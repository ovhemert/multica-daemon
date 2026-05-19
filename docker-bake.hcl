# docker-bake.hcl — multi-variant image build definition
#
# Tagging scheme
# ──────────────
#  Variant images   : ghcr.io/ovhemert/multica-daemon:<variant>
#                     ghcr.io/ovhemert/multica-daemon:<version>-<variant>   (when VERSION is set)
#  Bundled image    : ghcr.io/ovhemert/multica-daemon:all
#                     ghcr.io/ovhemert/multica-daemon:latest
#                     ghcr.io/ovhemert/multica-daemon:<version>             (when VERSION is set)
#                     ghcr.io/ovhemert/multica-daemon:<version>-all         (when VERSION is set)
#
# Usage
# ─────
#  Build all variants:
#    docker buildx bake
#
#  Build a single variant:
#    docker buildx bake claude
#
#  Build with a specific version tag:
#    VERSION=1.2.3 docker buildx bake
#
#  Push to registry:
#    docker buildx bake --push

variable "REGISTRY" {
  default = "ghcr.io/ovhemert/multica-daemon"
}

# Set VERSION to produce versioned tags (e.g. VERSION=1.2.3).
# Defaults to "latest" which suppresses versioned tags.
variable "VERSION" {
  default = "latest"
}

variable "CLAUDE_VERSION"   { default = "2.1.144" }
variable "CODEX_VERSION"    { default = "0.131.0" }
variable "COPILOT_VERSION"  { default = "1.0.50" }
variable "GEMINI_VERSION"   { default = "0.42.0" }
variable "MULTICA_VERSION"  { default = "0.3.3" }
variable "OPENCODE_VERSION" { default = "1.15.5" }
variable "PI_VERSION"       { default = "0.75.3" }

group "default" {
  targets = ["claude", "codex", "copilot", "gemini", "opencode", "pi", "all"]
}

# Shared base target — all variants inherit from this.
target "_common" {
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  args = {
    VERSION          = VERSION
    CLAUDE_VERSION   = CLAUDE_VERSION
    CODEX_VERSION    = CODEX_VERSION
    COPILOT_VERSION  = COPILOT_VERSION
    GEMINI_VERSION   = GEMINI_VERSION
    MULTICA_VERSION  = MULTICA_VERSION
    OPENCODE_VERSION = OPENCODE_VERSION
    PI_VERSION       = PI_VERSION
  }
}

target "claude" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "claude" }
  tags = compact([
    "${REGISTRY}:claude",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-claude" : "",
  ])
}

target "codex" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "codex" }
  tags = compact([
    "${REGISTRY}:codex",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-codex" : "",
  ])
}

target "copilot" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "copilot" }
  tags = compact([
    "${REGISTRY}:copilot",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-copilot" : "",
  ])
}

target "gemini" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "gemini" }
  tags = compact([
    "${REGISTRY}:gemini",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-gemini" : "",
  ])
}

target "opencode" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "opencode" }
  tags = compact([
    "${REGISTRY}:opencode",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-opencode" : "",
  ])
}

target "pi" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "pi" }
  tags = compact([
    "${REGISTRY}:pi",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-pi" : "",
  ])
}

# Bundled image — all CLIs included. Carries the :latest and :all tags.
target "all" {
  inherits = ["_common"]
  args     = { ENABLED_CLIS = "claude,codex,copilot,gemini,opencode,pi" }
  tags = compact([
    "${REGISTRY}:all",
    "${REGISTRY}:latest",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}" : "",
    VERSION != "latest" ? "${REGISTRY}:${VERSION}-all" : "",
  ])
}
