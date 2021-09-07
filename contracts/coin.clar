;; This contract defines the FT for coin used to submit artwork to the contest.
;;
;; Standard: https://github.com/stacksgov/sips/blob/main/sips/sip-009/sip-009-nft-standard.md

;; (impl-trait .ft-trait.ft-trait)

;; Improvements
;; - enable impl-trait
;; - set total supply
;; - standardize and distinguish error codes
;; - remove mint-for-creator

;; Error codes
(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-FAILED u2)

;; Constants
(define-constant CREATOR tx-sender)
(define-constant NAME "Bimba Coin")
(define-constant SYMBOL "BIM")
(define-constant DECIMALS u6)

;; Variables
(define-fungible-token coin)
(define-data-var token-uri (optional (string-ascii 256)) none)

;; Standard functions

(define-public (transfer (recipient principal) (amount uint)) 
  (ft-transfer? coin amount tx-sender recipient)
)

(define-read-only (get-name)
  (ok NAME)
)

(define-read-only (get-symbol)
  (ok SYMBOL)
)

(define-read-only (get-decimals)
  (ok DECIMALS)
)

(define-read-only (get-balance-of (user principal))
  (ok (ft-get-balance coin user))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply coin))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-public (set-token-uri (value (string-ascii 256)))
  (if 
    (is-eq tx-sender CREATOR) 
      (ok (var-set token-uri (some value))) 
    (err ERR-UNAUTHORIZED)))

;; Functions

(define-public (mint-for-creator)
  (begin 
    (asserts! (is-ok (ft-mint? coin u5 CREATOR)) (err ERR-FAILED))
    (ok (ft-get-balance coin CREATOR))
  )
)