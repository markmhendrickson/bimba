;; This contract defines the mining contest.

;; Improvements
;; - standardize error codes
;; - add function for increasing coin-amount for submitted artwork
;; - add function for increasing stx-amount for submitted vote

;; Error codes
(define-constant ERR-UNAUTHORIZED u1)
(define-constant ERR-FAILED u2)
(define-constant ERR-FAILED-TRANSFER u3)

;; Constants
(define-constant CREATOR tx-sender)
(define-constant CONTRACT (as-contract tx-sender))

;; Variables
(define-map artwork-submissions { submitter: principal, round: uint } { artwork-id: uint, coin-amount: uint})
(define-map vote-submissions { submitter: principal, round: uint } { artwork-id: uint, stx-amount: uint, round-previous-stx-total: uint })
(define-map stx-totals-per-round { round: uint } uint) ;; total stx submitted as part of votes per round
(define-map stx-totals-per-round-artwork { artwork-id: uint, round: uint } uint) ;; total stx submitted as part of votes per round per artwork

;; Public functions

(define-public (submit-artwork (token-uri (string-ascii 256)) (coin-amount uint))
  (let
    (
      (round (unwrap! (get-round) (err ERR-FAILED)))
      (artwork-id (unwrap! (contract-call? .artwork mint token-uri tx-sender) (err ERR-FAILED)))
    )
    (asserts! (if (> coin-amount u0) (is-ok (contract-call? .coin transfer CONTRACT coin-amount)) true) (err ERR-FAILED-TRANSFER))
    (asserts! (map-set artwork-submissions { submitter: tx-sender, round: round } { artwork-id: artwork-id, coin-amount: coin-amount }) (err ERR-FAILED))
    (ok (print { submitter: tx-sender, round: round, artwork-id: artwork-id, coin-amount: coin-amount }))
  )
)

(define-public (submit-vote (artwork-id uint) (stx-amount uint))
  (let
    (
      ;; disallow without u0 < stx-amount
      (round (unwrap! (get-round) (err ERR-FAILED)))
      (round-previous-stx-total (if (is-some (map-get? stx-totals-per-round { round: round })) (unwrap! (map-get? stx-totals-per-round { round: round }) (err ERR-FAILED)) u0))
    )
    (asserts! (if (> stx-amount u0) (is-ok (stx-transfer? stx-amount tx-sender CONTRACT)) true) (err ERR-FAILED-TRANSFER))
    (asserts! (map-set vote-submissions { submitter: tx-sender, round: round } { artwork-id: artwork-id, stx-amount: stx-amount, round-previous-stx-total: round-previous-stx-total }) (err ERR-FAILED))
    (map-set stx-totals-per-round { round: round } (+ round-previous-stx-total stx-amount))
    (map-set stx-totals-per-round-artwork { round: round, artwork-id: artwork-id } (+ round-previous-stx-total stx-amount))
    (ok (print { artwork-id: artwork-id, submitter: tx-sender, round: round, stx-amount: stx-amount }))
  )
)

;;(define-public (claim-vote-rewards (round uint))
;;  (let
;;    (
;;      (round (unwrap! (get-round) (err ERR-FAILED)))
;;      (vrfSample (unwrap! (contract-call? .vrf get-random-uint-at-block maturityHeight) (err ERR-FAILED)))
;;    )
;;  )
;;)

(define-read-only (get-vote-data (submitter principal) (round uint))
  (let
    (
      (vote-submission (map-get? vote-submissions { submitter: submitter, round: round }))
      (round-stx-total (map-get? stx-totals-per-round { round: round } ))
    )
    (ok (print { 
        artwork-id: (get artwork-id vote-submission), 
        stx-amount: (get stx-amount vote-submission), 
        round-previous-stx-total: (get round-previous-stx-total vote-submission),
        round-stx-total: round-stx-total
    }))
  )
)

(define-read-only (is-vote-winner (submitter principal) (round uint))
  (let
    (
      (vote-submission (map-get? vote-submissions { submitter: submitter, round: round }))
      (round-stx-total (unwrap! (map-get? stx-totals-per-round { round: round } ) (err u100)))
      (round-stx-total-artwork (map-get? stx-totals-per-round-artwork { round: round, artwork-id: (unwrap! (get artwork-id vote-submission) (err u101)) } ))
      (random-uint (unwrap! (contract-call? .vrf get-random-uint-at-block round) (err u102)))
      (winning-value (mod random-uint round-stx-total))
      (round-previous-stx-total (unwrap! (get round-previous-stx-total vote-submission) (err u103)))
      (low round-previous-stx-total)
      (high (+ round-previous-stx-total (unwrap! (get stx-amount vote-submission) (err u104))))
    )
    (ok (and (>= winning-value low) (<= winning-value high)))
  )
)

(define-read-only (get-total-stx-amount)
  (ok (stx-get-balance CONTRACT))
)

;; Private functions

(define-private (get-round)
  (ok block-height)
)

;; claim-artwork nft-address
;; claim-artwork-rewards nft-address