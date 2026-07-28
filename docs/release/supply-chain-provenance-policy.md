# Supply-chain provenance policy

This policy defines the minimum release evidence required before publishing an
Idelium component, package, image, or coordinated product release.

It applies to:

- `idelium-api`
- `idelium-web`
- `idelium-cli`
- `idelium-docker`
- generated release bundles, Docker images, Python distributions, npm
  artifacts, Composer artifacts, and CI report archives

## Release artifact identity

Every published artifact must be traceable to immutable source and build inputs.
Release notes or the release record must identify:

| Field | Requirement |
| --- | --- |
| Artifact name | Human-readable artifact name and repository. |
| Artifact version | SemVer package version, Docker tag, release tag, or documented product release version. |
| Source commit | Full 40-character Git commit SHA for the repository that produced the artifact. |
| License | `Apache-2.0` with the repository `LICENSE` file included or linked. |
| Build workflow | CI workflow name, run identifier, and timestamp when available. |
| Dependency inputs | Lockfile commit, package manager, and reviewed exception list. |
| Checksum or signature | SHA-256 checksum, registry digest, package hash, or signature when supported. |
| Rollback target | Previous compatible artifact or documented non-rollbackable reason. |

Moving branch names, mutable Docker tags, and locally rebuilt artifacts without a
recorded source commit cannot be used as release evidence.

## License and dependency checks

Before publication:

1. Each repository must contain a root `LICENSE` file using Apache License 2.0.
2. Package metadata must declare `Apache-2.0` where the package manager supports
   a license field.
3. Dependency lockfiles must be committed for package ecosystems that support
   lockfiles in Idelium repositories.
4. License or vulnerability exceptions must be reviewed, time-bounded, and
   linked from the release notes or security review.
5. Dependency updates must be reviewed separately from unrelated feature changes
   whenever practical.

## Checksums and signatures

Use the strongest verification supported by the artifact registry:

| Artifact type | Required evidence |
| --- | --- |
| Docker image | Immutable digest from the registry. |
| Python wheel or source distribution | SHA-256 checksum from the publish command or PyPI artifact metadata. |
| npm package or tarball | Integrity hash or SHA-256 checksum. |
| Composer package or archive | Lockfile reference and archive checksum when distributed outside Packagist. |
| CI report archive | SHA-256 checksum when retained outside the CI artifact store. |

If the registry does not expose signatures, publish the checksum in the release
record and keep the artifact immutable.

## CI gate

Run the non-mutating provenance gate before a coordinated release:

```bash
./scripts/supply-chain-provenance-gate.sh
```

The gate verifies local repository evidence only. It must not download
dependencies, publish artifacts, mutate files, or require credentials.

CI may add repository-specific scanners such as package audits, SBOM generation,
or license-report tooling. Those scanners must preserve redaction rules and must
not print private tokens, API keys, authorization headers, or customer data.

## Release note linkage

Each release note must link:

- this policy;
- the [release and rollback runbook](release-and-rollback-runbook.md);
- the [versioning and compatibility policy](versioning-and-compatibility-policy.md);
- any dependency/license exception approved for the release.

## Deployment and rollback implications

Deployment may proceed only when release artifacts are immutable and traceable.
Rollback uses the previous compatible artifact identified in the release record.
If a migration or external dependency prevents rollback, the release note must
state the forward-fix procedure and the operational approval required before
deployment.
