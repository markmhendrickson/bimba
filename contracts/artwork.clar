;; This contract defines the NFT for artwork as submitted to the contest.
;;
;; Standard: https://github.com/stacksgov/sips/blob/hstove-feat/sip-10-ft/sips/sip-010/sip-010-fungible-token-standard.md

;; (impl-trait .nft-trait.nft-trait)

;; Improvements
;; - enable impl-trait
;; - standardize and distinguish error codes
;; - optimize efficiency
;; - write tests

;; Error codes
(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-FAILED u2)

;; Constants
(define-constant CREATOR tx-sender)

;; Variables
(define-non-fungible-token artwork uint)
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var last-token-id uint u0)
(define-map token-uris uint (string-ascii 256))

;; Standard functions

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

(define-read-only (get-token-uri (id uint))
  (ok (map-get? token-uris id)))

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? artwork id)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
  (nft-transfer? artwork id sender recipient))

;; Functions

(define-public (mint (uri (string-ascii 256)) (recipient principal))
  (begin
    (asserts! (is-ok (nft-mint? artwork (+ (var-get last-token-id) u1) recipient)) (err ERR-FAILED))
    (asserts! (is-eq (map-set token-uris (+ (var-get last-token-id) u1) uri) true) (err ERR-FAILED))
    (asserts! (is-eq (var-set last-token-id (+ (var-get last-token-id) u1)) true) (err ERR-FAILED))
    (ok (var-get last-token-id))
  )
)