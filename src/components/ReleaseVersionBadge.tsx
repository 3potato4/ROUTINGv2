import { RELEASE_VERSION } from "@shared/releaseVersion";

interface ReleaseVersionBadgeProps {
  /** Larger pill for loading / error full-screen states */
  prominent?: boolean;
}

export default function ReleaseVersionBadge({ prominent = false }: ReleaseVersionBadgeProps) {
  return (
    <span
      className={`release-version-badge${prominent ? " release-version-badge--prominent" : ""}`}
      title="Application release"
    >
      {RELEASE_VERSION}
    </span>
  );
}
