;; Brand Manager Verification Contract
;; Validates and manages brand managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))
(define-constant ERR_INVALID_BRAND (err u103))

;; Data structures
(define-map brand-managers
  { manager: principal }
  {
    brand-name: (string-ascii 50),
    verified: bool,
    verification-date: uint,
    reputation-score: uint
  }
)

(define-map brands
  { brand-id: uint }
  {
    name: (string-ascii 50),
    owner: principal,
    created-at: uint,
    active: bool
  }
)

(define-data-var next-brand-id uint u1)

;; Register a new brand
(define-public (register-brand (brand-name (string-ascii 50)))
  (let ((brand-id (var-get next-brand-id)))
    (map-set brands
      { brand-id: brand-id }
      {
        name: brand-name,
        owner: tx-sender,
        created-at: block-height,
        active: true
      }
    )
    (var-set next-brand-id (+ brand-id u1))
    (ok brand-id)
  )
)

;; Verify a brand manager
(define-public (verify-manager (manager principal) (brand-name (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? brand-managers { manager: manager })) ERR_ALREADY_VERIFIED)
    (map-set brand-managers
      { manager: manager }
      {
        brand-name: brand-name,
        verified: true,
        verification-date: block-height,
        reputation-score: u100
      }
    )
    (ok true)
  )
)

;; Check if manager is verified
(define-read-only (is-verified-manager (manager principal))
  (match (map-get? brand-managers { manager: manager })
    manager-data (get verified manager-data)
    false
  )
)

;; Get manager details
(define-read-only (get-manager-details (manager principal))
  (map-get? brand-managers { manager: manager })
)

;; Get brand details
(define-read-only (get-brand-details (brand-id uint))
  (map-get? brands { brand-id: brand-id })
)
