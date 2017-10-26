# Maintainer: Rob Wu <rob@robwu.nl>
pkgname=mkinitcpio-encswap
pkgver=0.1.0
pkgrel=1
pkgdesc="mkinitcpio hook to use an encrypted swap device with a temporary keyfile on the encrypted filesystem for hibernation."
arch=(any)
url="" # TODO: When possible, https://aur.archlinux.org/packages/mkinitcpio-encswap
license=("unknown")
depends=("mkinitcpio" "cryptsetup")
conflicts=()
backup=(etc/encswap.conf)
install=mkinitcpio-encswap.install
source=("50-encswap.conf"
        "encswap.conf"
        "encswap_hook"
        "encswap_install"
        "encswap.service"
        "encswap.sh")
sha256sums=("SKIP"
            "SKIP"
            "SKIP"
            "SKIP"
            "SKIP"
            "SKIP")

package() {
    install -Dm 644 encswap.conf "${pkgdir}/etc/encswap.conf"
    install -Dm 644 encswap_hook "${pkgdir}/usr/lib/initcpio/hooks/encswap"
    install -Dm 644 encswap_install "${pkgdir}/usr/lib/initcpio/install/encswap"

    # https://github.com/systemd/systemd/pull/3006#issuecomment-211347763
    install -Dm 644 50-encswap.conf "${pkgdir}/etc/systemd/system/systemd-logind.service.d/50-encswap.conf"
    install -Dm 644 encswap.service "${pkgdir}/etc/systemd/system/encswap.service"
    install -Dm 744 encswap.sh "${pkgdir}/usr/lib/systemd/scripts/encswap.sh"
}
