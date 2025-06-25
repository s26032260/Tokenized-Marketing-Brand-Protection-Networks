;; Enforcement Coordination Contract
;; Coordinates brand enforcement actions

(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_INVALID_ACTION (err u401))
(define-constant ERR_NOT_FOUND (err u402))

;; Data structures
(define-map enforcement-actions
  { action-id: uint }
  {
    brand-name: (string-ascii 50),
    target: principal,
    action-type: (string-ascii 30),
    initiator: principal,
    timestamp: uint,
    status: (string-ascii 20),
    priority: uint,
    evidence-refs: (list 5 uint)
  }
)

(define-map enforcement-teams
  { team-id: uint }
  {
    brand-name: (string-ascii 50),
    lead: principal,
    members: (list 10 principal),
    active: bool,
    cases-handled: uint
  }
)

(define-data-var next-action-id uint u1)
(define-data-var next-team-id uint u1)

;; Initiate enforcement action
(define-public (initiate-enforcement
  (brand-name (string-ascii 50))
  (target principal)
  (action-type (string-ascii 30))
  (priority uint)
  (evidence-refs (list 5 uint))
)
  (let ((action-id (var-get next-action-id)))
    (map-set enforcement-actions
      { action-id: action-id }
      {
        brand-name: brand-name,
        target: target,
        action-type: action-type,
        initiator: tx-sender,
        timestamp: block-height,
        status: "initiated",
        priority: priority,
        evidence-refs: evidence-refs
      }
    )
    (var-set next-action-id (+ action-id u1))
    (ok action-id)
  )
)

;; Create enforcement team
(define-public (create-enforcement-team
  (brand-name (string-ascii 50))
  (members (list 10 principal))
)
  (let ((team-id (var-get next-team-id)))
    (map-set enforcement-teams
      { team-id: team-id }
      {
        brand-name: brand-name,
        lead: tx-sender,
        members: members,
        active: true,
        cases-handled: u0
      }
    )
    (var-set next-team-id (+ team-id u1))
    (ok team-id)
  )
)

;; Update action status
(define-public (update-action-status (action-id uint) (new-status (string-ascii 20)))
  (match (map-get? enforcement-actions { action-id: action-id })
    action-data
    (begin
      (map-set enforcement-actions
        { action-id: action-id }
        (merge action-data { status: new-status })
      )
      (ok true)
    )
    ERR_NOT_FOUND
  )
)

;; Get enforcement action
(define-read-only (get-enforcement-action (action-id uint))
  (map-get? enforcement-actions { action-id: action-id })
)

;; Get team details
(define-read-only (get-team-details (team-id uint))
  (map-get? enforcement-teams { team-id: team-id })
)
