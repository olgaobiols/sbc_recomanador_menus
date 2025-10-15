;;; ---------------------------------------------------------
;;; code.clp
;;; Translated by owl2clips
;;; Translated to CLIPS from ontology ontology.ttl
;;; :Date 20/10/2024 11:32:35

(defmodule MAIN (export ?ALL))
; (defclass Period
;     (is-a USER)
;     (role concrete)
;     (pattern-match reactive)
;     (slot year_beginning
;         (type INTEGER)
;         (create-accessor read-write))
;     (slot year_end
;         (type INTEGER)
;         (create-accessor read-write))
; )

; (defclass Theme
;     (is-a USER)
;     (role concrete)
;     (pattern-match reactive)
;     (multislot labels
;         (type STRING)
;         (create-accessor read-write))
; )

; (defclass Author
;     (is-a USER)
;     (role concrete)
;     (pattern-match reactive)
;     (slot author_id
;         (type INTEGER)
;         (create-accessor read-write))
;     (slot author_name
;         (type STRING)
;         (create-accessor read-write))
; )

; (defclass Artwork
;     (is-a USER)
;     (role concrete)
;     (pattern-match reactive)
;     (slot artwork_name
;         (type STRING)
;         (create-accessor read-write))
;     ;; Relation with author
;     (slot created_by
;         (type INSTANCE)
;         (allowed-classes Author) 
;         (create-accessor read-write))
;     ;; Relation with room
;     (slot artwork_in_room
;         (type INSTANCE)
;         (allowed-classes Room) 
;         (create-accessor read-write))
;     (slot artwork_id
;         (type INTEGER)
;         (create-accessor read-write))
;     ;; Relation with theme
;     (slot artwork_theme
;         (type INSTANCE)
;         (allowed-classes Theme)
;         (create-accessor read-write))
;     ;; Relation with period
;     (slot artwork_in_period
;         (type INSTANCE)
;         (allowed-classes Period)
;         (create-accessor read-write))  
;     ;; Default time to see the artwork
;     (slot default_time
;         (type INTEGER)
;         (create-accessor read-write))  
; )


; (defclass Museum
;     (is-a USER)
;     (role concrete)
;     (pattern-match reactive)
;     (slot museum_id
;         (type INTEGER)
;         (create-accessor read-write))
;     (slot museum_name
;         (type STRING)
;         (create-accessor read-write))
; )

; (defclass Room
;     (is-a USER)
;     (role concrete)
;     (pattern-match reactive)
;     (multislot adjacent_room
;         (type INSTANCE)
;         (allowed-classes Room) 
;         (create-accessor read-write))
;     (slot room_in_museum
;         (type INSTANCE)
;         (allowed-classes Museum) 
;         (create-accessor read-write))
;     (slot room_id
;         (type INTEGER)
;         (create-accessor read-write))
;     (slot is_entry
;         (type SYMBOL)
;         (allowed-values TRUE FALSE)
;         (create-accessor read-write))
;     (slot is_exit
;         (type SYMBOL)
;         (allowed-values TRUE FALSE)
;         (create-accessor read-write))
;     (slot is_elevator
;         (type SYMBOL)
;         (allowed-values TRUE FALSE)
;         (create-accessor read-write))
;     (slot is_stairs
;         (type SYMBOL)
;         (allowed-values TRUE FALSE)
;         (create-accessor read-write))
; )

(defclass SpecificProblem
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;; Number of people in the group
    (slot num_people
        (type INTEGER)
        (create-accessor read-write))
    ;; Favorite author
    (slot favorite_author
        (type INTEGER)
        (create-accessor read-write))
    ;; Favorite period
    (slot favorite_period
        (type INTEGER)
        (create-accessor read-write))
    ;; Favorite theme
    (slot favorite_theme
        (type STRING)
        (create-accessor read-write))
    ;; For guided visits
    (slot guided_visit
        (type SYMBOL)
        (create-accessor read-write))
    ;; There are minors
    (slot minors
        (type SYMBOL)
        (create-accessor read-write))
    ;; Number of experts in the group
    (slot num_experts
        (type INTEGER)
        (create-accessor read-write))
    ;; Number of museums the group has visited previously
    (slot past_museum_visits
        (type INTEGER)
        (create-accessor read-write))
)

(defclass AbstractProblem
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot preferred_period
        (type INSTANCE)
        (allowed-classes Period)
        (create-accessor read-write))
    (slot preferred_author
        (type INSTANCE)
        (allowed-classes Author) 
        (create-accessor read-write))
    ;;; Relate the abstract problem with the specific problem
    (slot related_to_SpecificProblem
        (type INSTANCE)
        (allowed-classes SpecificProblem) 
        (create-accessor read-write))
    ;;; Level of art knowledge (1 = low, 2 = medium, 3 = high, 4 = expert)
    (slot art_knowledge
        (type INTEGER)
        (create-accessor read-write))
    ;;; Size of the group
    (slot group_size
        (type INTEGER)
        (create-accessor read-write))
    ;;; Type of group (casual, family, scholar)
    (slot group_type
        (type STRING)
        (create-accessor read-write))
    (multislot preferred_themes
        (type STRING)
        (create-accessor read-write))
    ;;; Time coefficient for the visit (1 = normal, >1 = longer, <1 = shorter)
    (slot time_coeficient
        (type INTEGER)
        (create-accessor read-write))
)

(defclass AbstractSolution
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Relates the abstract solution with the abstract problem
    (slot related_to_AbstractProblem
        (type INSTANCE)
        (allowed-classes AbstractProblem) 
        (create-accessor read-write))
)

(defclass SpecificSolution
   (is-a USER)
   (role concrete)
   (pattern-match reactive)
   ;; Someone in the group has reduced mobility
	(slot reduced_mobility
		(type SYMBOL)
		(allowed-values TRUE FALSE)
		(create-accessor read-write))
    ;; Total number of days for the visit
	(slot total_days
		(type INTEGER)
		(create-accessor read-write))
	(slot daily_minutes
    ;; Total number of minutes per day
		(type INTEGER)
		(create-accessor read-write))
)

(deftemplate match
    (slot artwork (type INSTANCE))
    ;; Match score based on the preferences
    (slot match_type (type INTEGER))    
    ;; Actual time to see the artwork (updated based on AbstractProblem)
    (slot artwork_time (type INTEGER))) 

(deftemplate day-artwork
   (slot artwork (type INSTANCE))
   (slot num_day (type INTEGER))
)

(deftemplate day-time
    (slot day (type INTEGER))
    (slot time_sum (type INTEGER) (default 0))
)

(deftemplate max_score
    (slot value (type INTEGER))
)

(deftemplate search-node
    (slot room)
    (multislot room_path)
)

(deftemplate room-connections-count
    (slot room (type INSTANCE))
    (slot num_connections (type INTEGER))
)

;(defmessage-handler SpecificProblem info primary ()
;    (printout t "num_people: " ?self:num_people crlf)
;    (printout t "minors: " ?self:minors crlf)
;    (printout t "guided_visit: " ?self:guided_visit crlf)
;    (printout t "num_experts: " ?self:num_experts crlf)
;    (printout t "past_museum_visits: " ?self:past_museum_visits crlf))

; (deffunction ask-and-validate-boolean (?prompt)
;     (bind ?valid FALSE)
;     (bind ?response nil)  ;; Ensure ?response is bound before the loop
;     (while (not ?valid)
;         (printout t ?prompt " (yes/no): " crlf)
;         (bind ?input (readline))
;         (bind ?response (lowcase ?input))  ;; Convert the response to lowercase
;         (if (or (eq ?response "yes") (eq ?response "no")) then
;             (bind ?valid TRUE)  ;; Valid response
;         else
;             (printout t "Invalid input. Please answer with 'yes' or 'no'." crlf)  ;; Error message for invalid input
;         )
;     )
;     ?response  ;; Return the valid response
; )

; (deffunction ask-and-validate-integer (?prompt ?min ?max)
;     (bind ?valid FALSE)
;     (bind ?response nil)  ;; Ensure ?response is bound before the loop
;     (while (not ?valid)
;         (printout t ?prompt " (" ?min " to " ?max "): " crlf)
;         (bind ?response (read))
;         (if (integerp ?response) then
;             (if (and (>= ?response ?min) (<= ?response ?max)) then
;                 (bind ?valid TRUE)
;             else
;                 (printout t "Invalid input. Please enter a number between " ?min " and " ?max "." crlf)
;             )
;         else
;             (printout t "Invalid input. Please enter an integer number." crlf)
;         )
;     )
;     ?response  ;; Return the valid response
; )


; (deffunction select-five-random-authors ()
;     ;; Obtenir la llista de tots els autors disponibles
;     (bind ?all-authors (find-all-instances ((?author Author)) TRUE))
;     (bind ?selected-authors (create$))
;     (bind ?count 0)

;     ;; Si hi ha menys de 5 autors disponibles, retorna'ls tots
;     (if (< (length$ ?all-authors) 5) then
;         (return ?all-authors)
;     )

;     ;; Selecciona fins a 5 autors de manera aleatòria sense repetir-los
;     (while (< ?count 5)
;         (bind ?index (+ 1 (mod (random 1 (length$ ?all-authors)) (length$ ?all-authors))))
;         (bind ?author (nth$ ?index ?all-authors))
        
;         ;; Afegim l'autor seleccionat i l'eliminem de la llista disponible
;         (bind ?selected-authors (create$ ?selected-authors ?author))
;         (bind ?all-authors (delete$ ?all-authors ?index ?index))
        
;         ;; Incrementa el comptador d'autors seleccionats
;         (bind ?count (+ ?count 1))
;     )
;     ?selected-authors
; )


; (deffunction ask-and-validate-period (?prompt ?min ?max)
;     (bind ?valid FALSE)
;     (bind ?response nil)  ;; Ensure ?response is bound before the loop
;     (while (not ?valid)
;         (printout t ?prompt " (" ?min " to " ?max "): " crlf)
;         (bind ?response (read))
;         (if (or (and (integerp ?response) (eq ?response -1))  ;; Allow -1 as a special case for Period
;                 (and (integerp ?response) (>= ?response ?min) (<= ?response ?max)))
;             then
;             (bind ?valid TRUE)
;         else
;             (printout t "Invalid input. Please enter a number between " ?min " and " ?max " (or -1 if you don't have a favorite year)." crlf)
;         )
;     )
;     ?response  ;; Return the valid response
; )

;;; ---------------------------------------------------------


;;; Main Flow
;;; ---------------------------------------------------------

(defmodule start (import MAIN ?ALL))

(defrule start::initialize-system
    =>
    ;;; (unwatch rules)  ;;
    ; Define fact for the initial setup
    (load "instances.clp")
    (reset)
    (printout t "Setting up adjacency relations..." crlf)
    (send [room101] put-adjacent_room (create$ [room103] [room102] [stair_2_to_1_0]))
    (send [room102] put-adjacent_room (create$ [room101] [room100]))
    (send [room103] put-adjacent_room (create$ [room101] [room100]))
    (send [room201] put-adjacent_room (create$ [room203] [room202] [stair_2_to_1_0]))
    (send [room202] put-adjacent_room (create$ [room201]))
    (send [room203] put-adjacent_room (create$ [room201] [elevator_2_to_1]))
    (send [room100] put-adjacent_room (create$ [room102] [room103] [elevator_2_to_1]))
    (send [elevator_2_to_1] put-adjacent_room (create$ [room203] [room100]))
    (send [stair_2_to_1_0] put-adjacent_room (create$ [room201] [room101]))



    (printout t "Welcome to the Museum Route Planner!" crlf)
    (printout t "We're excited to guide you in creating a personalized museum experience." crlf)
    (printout t "Let's start by learning more about your preferences, so we can craft the perfect art adventure for you!" crlf)
    (printout t crlf)
    (focus steps)
)

; (defmodule steps (import MAIN ?ALL))

; (defrule steps::Step_A
;     (declare (salience -5)) 
;     =>
;     (focus VisitPreferences))

; (defrule steps::Step_B
;     (declare (salience -10)) 
;     =>
;     (focus Abstraction))

; (defrule steps::Step_C
;     (declare (salience -20))
;     =>
;     (focus Association))

; (defrule steps::Step_D
;     (declare (salience -30))
;     =>
;     (focus Refinement))

;;; Step A: Visit Preferences
;;; ---------------------------------------------------------
; (defmodule VisitPreferences (import MAIN ?ALL) (export ?ALL))

; (defrule VisitPreferences::ask-num-people
;     (not (problem ?problem))  ;; Verify that the problem instance does not exist
;     =>
;     (bind ?problem (make-instance my-problem of SpecificProblem))  ;; Create a new instance of SpecificProblem
;     (assert (problem ?problem))  ;; Insert the problem instance into the fact list
;     (bind ?num-people (ask-and-validate-integer "How many people will join the visit?" 1 50))
;     (send ?problem put-num_people ?num-people)
;     (assert (asked-num-people)) ;; Assert a fact to indicate that the question has been asked
; )

; (defrule VisitPreferences::ask-children
;     ?problem-fact <- (problem ?problem)
;     (exists (asked-num-people))
;     (not (exists (asked-children)))
;     =>
;     (bind ?children (ask-and-validate-boolean "Are there children under 12?"))
;     (if (eq ?children "yes")
;         then (send ?problem put-minors TRUE)
;         else (send ?problem put-minors FALSE))
;     (assert (asked-children))
; )

; (defrule VisitPreferences::ask-guided-visit
;     ?problem-fact <- (problem ?problem)
;     (exists (asked-children))
;     (not (exists (asked-guided-visit)))
;     =>
;     (bind ?guided (ask-and-validate-boolean "Would you like a guided visit?"))
;     (if (eq ?guided "yes")
;         then (send ?problem put-guided_visit TRUE)
;         else (send ?problem put-guided_visit FALSE))
;     (assert (asked-guided-visit))
; )

; (defrule VisitPreferences::ask-num-experts
;     ?problem-fact <- (problem ?problem)
;     (exists (asked-guided-visit))
;     (not (exists (asked-num-experts)))
;     =>
;     ;; Get the number of people in the group
;     (bind ?num-people (send ?problem get-num_people))

;     ;; Ask for the number of experts ensuring it does not exceed the number of people in the group
;     (bind ?valid FALSE)
;     (while (not ?valid)
;         (bind ?num-experts (ask-and-validate-integer 
;             (str-cat "How many experts are in the group? (Cannot exceed " ?num-people "): ") 
;             0 
;             ?num-people))
;         ;; Verify that the number of experts is less than or equal to the number of people
;         (if (<= ?num-experts ?num-people)
;             then (bind ?valid TRUE)
;             else (printout t "The number of experts cannot be greater than the number of people in the group." crlf)
;         )
;     )

;     ;; Assign the number of experts to the instance of SpecificProblem
;     (send ?problem put-num_experts ?num-experts)
;     (assert (asked-num-experts))
; )


; (defrule VisitPreferences::ask-past-visits
;     ?problem-fact <- (problem ?problem)
;     (exists (asked-num-experts))
;     (not (exists (asked-past-visits)))
;     =>
;     (bind ?past-visits (ask-and-validate-integer "How many museums have you visited before?" 0 50))
;     (send ?problem put-past_museum_visits ?past-visits)
;     (assert (asked-past-visits))
; )

; (defrule VisitPreferences::ask-favorite-period
;     ?problem-fact <- (problem ?problem)
;     (exists (asked-past-visits))
;     (not (exists (asked-favorite-period)))
;     =>
;     (bind ?favorite-period (ask-and-validate-period "Enter the year of your favorite art period (or type -1 for any period)" 1000 1900))
    
;     (send ?problem put-favorite_period ?favorite-period)
;     (assert (asked-favorite-period))
; )

; (defrule VisitPreferences::ask-favorite-theme
;     ?problem-fact <- (problem ?problem)
;     (exists (asked-favorite-period))
;     (not (exists (asked-favorite-theme)))
;     =>
;     (printout t "Which of these themes do you prefer?" crlf)
;     (printout t "0. Any theme" crlf)    
;     (printout t "1. Emotional" crlf)
;     (printout t "2. Historical" crlf)
;     (printout t "3. Religious" crlf)
;     (printout t "4. Natural" crlf)
;     (printout t "5. Mystical" crlf)     
;     (bind ?favorite-theme (ask-and-validate-integer "Enter the number of the theme?" 0 5))
;     (send ?problem put-favorite_theme ?favorite-theme)
;     (assert (asked-favorite-theme))
; )


; (defrule VisitPreferences::ask-preferred-author
;     (problem ?problem)
;     (exists (asked-favorite-theme))
;     (not (exists (asked-preferred-author)))
;     =>
;     ;; Get 5 random authors to choose from
;     (bind ?selected-authors (select-five-random-authors))
    
;     ;; Show the list of authors to the user
;     (printout t "Top authors:" crlf)
;     (bind ?index 1)
;     (foreach ?author ?selected-authors
;         (printout t ?index ". " (send ?author get-author_name) crlf)
;         (bind ?index (+ ?index 1))
;     )

;     ;; Read the user's choice of author
;     (bind ?chosen-author-index (ask-and-validate-integer "Choose your favourite author between these (0 if you don't have any preferences)" 0 5))

;     ;; Ensure the index is diff from 0
;     (if (not (eq ?chosen-author-index 0))
;         then
;         (bind ?preferred-author (nth$ ?chosen-author-index ?selected-authors))
;         else
;         (bind ?preferred-author nil)
;     )
;     ;; Assign the preferred author to the SpecificProblem instance
;     (send ?problem put-favorite_author ?preferred-author)
;     (assert (asked-preferred-author))
;     (printout t "Correctly assigned author." crlf)
; )
;;; ---------------------------------------------------------

;;; Step B: Abstraction
;;; ---------------------------------------------------------
(defmodule Abstraction (import MAIN ?ALL) (import VisitPreferences ?ALL) (export ?ALL))

;;; Rule to create an AbstractProblem instance based on SpecificProblem
(defrule Abstraction::create-abstract-problem
    ;; Conditions:
    ;; - There is a SpecificProblem instance
    ;; - There is no AbstractProblem instance yet
    (problem ?sp)
    (not (abstract-problem ?ap))
    =>
    ;; Actions:
    ;; Create an instance of AbstractProblem
    (bind ?ap (make-instance my-abstract-problem of AbstractProblem))
    (send ?ap put-related_to_SpecificProblem ?sp)
    
    ;; Assign group_size based on num_people
    (bind ?num-people (send ?sp get-num_people))
    (bind ?group-size
        (if (< ?num-people 1) then
            1
        else
            (if (and (>= ?num-people 1) (<= ?num-people 5)) then
                2
            else
                (if (and (> ?num-people 5) (<= ?num-people 15)) then
                    3
                else
                    4
                )
            )
        )
    )
    (send ?ap put-group_size ?group-size)
    
    ;; Assign group_type based on group_size and minors
    (bind ?has-minors (send ?sp get-minors))
    (bind ?group-type 
        (if (and (eq ?has-minors TRUE) (< ?group-size 3)) then
            "family"
        else 
            (if (and (eq ?has-minors TRUE) (>= ?group-size 3)) then
                "scholar"
            else
                "casual"
            )
        )
    )
    (send ?ap put-group_type ?group-type)
    
    ;; Assign art_knowledge based on num_experts and  past_museum_visits
    (bind ?num-experts (send ?sp get-num_experts))
    (bind ?num-people (send ?sp get-num_people))
    (bind ?past-visits (send ?sp get-past_museum_visits))
    ;; Calculate expertise percentage
    (bind ?expertise (/ ?num-experts ?num-people))
    (bind ?art-knowledge
        (if (or (< ?past-visits 10) (< ?expertise 25)) then
            1
        else
            (if (or (and (>= ?past-visits 10) (<= ?past-visits 20))
                (and (>= ?expertise 25) (< ?expertise 50))) then    
                2
            else
                (if (or (and (> ?past-visits 20) (<= ?past-visits 30))
                    (and (>= ?expertise 50) (< ?expertise 75))) then
                    3
                else
                    4
                )
            )
        )
    )
    (send ?ap put-art_knowledge ?art-knowledge)

    ;; Assign the preferred author based on favorite_author
    (bind ?preferred-author (send ?sp get-favorite_author))
    (send ?ap put-preferred_author ?preferred-author)

    (printout t "Assigned preferred author." crlf)
    
    (bind ?favorite-year (send ?sp get-favorite_period))

    ;; Find all instances of `Period` that contain the favorite year
    (if (eq ?favorite-year -1) then
        (bind ?matching-periods (find-all-instances ((?p Period)) TRUE))  
    else
        (bind ?matching-periods 
            (find-all-instances ((?p Period))
                (and (<= (send ?p get-year_beginning) ?favorite-year)
                    (>= (send ?p get-year_end) ?favorite-year))))
    )

    (send ?ap put-preferred_period (create$ ?matching-periods))
    
    ;; Confirmation message
    (printout t "Assigned preferred periods based on favorite year: " ?favorite-year crlf)


    ;; Get the favorite_theme from SpecificProblem
    (bind ?fav-theme (send ?sp get-favorite_theme))

    (bind ?selected-themes
        (if (eq ?fav-theme 0) then
            (find-all-instances ((?t Theme)) TRUE)  
        else
            (if (eq ?fav-theme 1) then
                (send [emotional] get-labels)
            else
                (if (eq ?fav-theme 2) then
                    (send [historical] get-labels)
                else
                    (if (eq ?fav-theme 3) then
                        (send [religious] get-labels)
                    else
                        (if (eq ?fav-theme 4) then
                            (send [natural] get-labels)
                        else
                            (send [mystical] get-labels)
                        )
                    )
                )
            )
        )
    )


    ;; Assignment of theme labels to `preferred_themes`
    (send ?ap put-preferred_themes ?selected-themes)
    
    ;; Assign time-coefficient based on group_type, group_size, and art_knowledge
    (bind ?guided-visit (send ?sp get-guided_visit))
    (bind ?time-coef
        (if (eq ?guided-visit TRUE) then
            1.5
        else
            (if (eq ?group-type "scholar") then
                2
            else
                (if (eq ?group-type "family") then
                    1.75
                else
                    (+ 1 (* ?group-size 0.25) (* ?art-knowledge 0.25))
                )
            )
        )
    )
    (send ?ap put-time_coeficient ?time-coef)
    
    ;; Insert the AbstractProblem instance into the fact list
    (assert (abstract-problem ?ap))
    
    ;; Confirmation message
    (printout t "AbstractProblem instance created and all attributes assigned." crlf)
)

;;; Rule to verify the values assigned to AbstractProblem
(defrule Abstraction::verify-abstract-problem
    ;; Condition:
    ;; - There is an instance of AbstractProblem
    (abstract-problem ?ap)
    (exists (asked-preferred-author))
    =>
    ;; Action:
    ;; - Show the details of the AbstractProblem instance
    (printout t "AbstractProblem Details:" crlf)
    (printout t "group_size: " (send ?ap get-group_size) crlf)
    (printout t "group_type: " (send ?ap get-group_type) crlf)
    (printout t "art_knowledge: " (send ?ap get-art_knowledge) crlf)
    (printout t "preferred_period: " (send ?ap get-preferred_period) crlf)
    (printout t "preferred_author: " (send ?ap get-preferred_author) crlf)
    (printout t "preferred_themes: " (send ?ap get-preferred_themes) crlf)
    (printout t "time_coefficient: " (send ?ap get-time_coeficient) crlf)
)

;;; Step C: Association
;;; ---------------------------------------------------------
(defmodule Association (import MAIN ?ALL) (import Abstraction ?ALL) (export ?ALL))

(defrule Association::matching
    ;; Verify that there is an AbstractProblem instance and no AbstractSolution instance
    (abstract-problem ?ap)
    (not (abstract-solution ?as))
    =>
    ;; Create an instance of AbstractSolution
    (bind ?as (make-instance my-abstract-solution of AbstractSolution))
    (send ?as put-related_to_AbstractProblem ?ap)  ;; Relate the AbstractSolution to the AbstractProblem

    ;; Initialize variables for match score and max score
    (bind ?match-score 0)
    (bind ?max-score 0)

    ;; Obtain the preferred author from the AbstractProblem
    (bind ?preferred-author (send ?ap get-preferred_author))

    ;; If the preferred author is `nil` (i.e., "any artist"), increment the `match-score`
    (if (eq ?preferred-author nil) then
        (bind ?match-score (+ ?match-score 1))
    else
        ;; Only get the `author_id` if the preferred author is not `nil`
        (bind ?preferred-author-id (send ?preferred-author get-author_id))
    )

    ;; Obtain the preferred themes from the AbstractProblem
    (bind ?preferred-themes (send ?ap get-preferred_themes))

    ;; Obtain the preferred period from the AbstractProblem
    (bind ?preferred-periods (send ?ap get-preferred_period))

    ;; Find all instances of Artwork
    (bind ?artworks (find-all-instances ((?artwork Artwork)) TRUE))

    ;; Iterate over each artwork instance
    (foreach ?artwork ?artworks
        ;; Check author match
        (bind ?artwork-author (send ?artwork get-created_by))
        (bind ?artwork-author-id (send ?artwork-author get-author_id))  ;; Obtain the author_id of the artwork

        ;; Increment `match-score` if the author matches or if `preferred_author` is "any"
        (if (or (eq ?preferred-author nil) (eq ?artwork-author-id ?preferred-author-id)) then
            (bind ?match-score (+ ?match-score 1))
        )

        ;; Check theme match
        (bind ?artwork-theme (send ?artwork get-artwork_theme))
        (if (or (eq (length$ ?preferred-themes) 0)  
                (member$ ?artwork-theme ?preferred-themes)) then
            ;; Increment match-score by 1 if theme matches
            (bind ?match-score (+ ?match-score 1))
)

        ;; Check period match
        (bind ?artwork-period (send ?artwork get-artwork_in_period))
        (if (or (eq ?preferred-periods ANY) (member$ ?artwork-period ?preferred-periods)) then
            ;; Increment `match-score` by 1 if the period matches or if "any period" is selected
            (bind ?match-score (+ ?match-score 1))
        )

        ;; Check if this artwork's match-score is the highest so far
        (if (> ?match-score ?max-score) then
            (bind ?max-score ?match-score)
        )

        ;; Obtain the default time to see the artwork
        (bind ?default-time (send ?artwork get-default_time))

        ;; Obtain the time coefficient from the AbstractProblem
        (bind ?time-coef (send ?ap get-time_coeficient))

        ;; Calculate the final time to see the artwork based on the time coefficient
        (bind ?final-time (* ?default-time ?time-coef))

        ;; Create a new instance of Match with the artwork, match score, and final time
        (assert (match (artwork ?artwork) (match_type ?match-score) (artwork_time ?final-time)))

        ;; Reset match score for the next artwork
        (bind ?match-score 0)
    )

    ;; Insert the max_score as a fact after all artworks have been evaluated
    (assert (max_score (value ?max-score)))

    ;; Insert the instance of AbstractSolution into the fact list
    (assert (abstract-solution ?as))

    ;; Confirmation message
    (printout t "AbstractSolution instance created, max score registered, and match facts generated." crlf)
)

;;; Step D: Refinement
;;; ---------------------------------------------------------
(defmodule Refinement (import MAIN ?ALL) (import Association ?ALL))

(defrule Refinement::ask-num-days
    (not (specific-solution ?specific-solution))
    =>
	 (bind ?specific-solution (make-instance specific-solution of SpecificSolution))
	 (assert (specific-solution ?specific-solution))
    (bind ?num-days (ask-and-validate-integer "How many days would you like to visit?" 1 7))
    (send ?specific-solution put-total_days ?num-days)
    (assert (asked-num-days)) 
)

(defrule Refinement::ask-daily-hours
    ?specific-solution-fact <- (specific-solution ?specific-solution)  
    (exists (asked-num-days))
    (not (exists (asked-daily-hours))) 
    =>
    (bind ?daily-hours (ask-and-validate-integer "How many daily hours will you dedicate to the visit?" 1 12))
	 (bind ?daily-minutes (* ?daily-hours 60))
    (send ?specific-solution put-daily_minutes ?daily-minutes) ;;; Convert hours to minutes
    (assert (asked-daily-hours))
)

(defrule Refinement::ask-mobility
	 ?specific-solution-fact <- (specific-solution ?specific-solution)
	 (exists (asked-daily-hours))
    (not (exists (asked-mobility)))
    =>
    (bind ?reduced_mobility (ask-and-validate-boolean "Is there someone with reduced mobility?"))
    (if (eq ?reduced_mobility "yes")
        then (send ?specific-solution put-reduced_mobility TRUE)
        else (send ?specific-solution put-reduced_mobility FALSE))
    (assert (asked-mobility))
)

(defrule Refinement::room-connections-count
    ?specific-solution-fact <- (specific-solution ?specific-solution)
    (not (exists (room-connections-count-initialized)))
    (exists (asked-mobility))
    =>
    (bind ?rooms (find-all-instances ((?r Room)) TRUE))
    (foreach ?room ?rooms
        (bind ?is_entry (send ?room get-is_entry))
        (bind ?adjacent-rooms (send ?room get-adjacent_room))
        (bind ?num-connections (length$ ?adjacent-rooms))
        (if (eq ?is_entry TRUE)
            then (bind ?num-connections (+ ?num-connections 1)) ; Add 1 for the entry room to simulate the edge that leads to the museum entrance at the beginning
        )
        (assert (room-connections-count (room ?room) (num_connections ?num-connections)))
    )
    (assert (room-connections-count-initialized))
)

;;; Function to retrieve the entry room
(deffunction Refinement::get_entry_room ()
    ; Find the entry room
    (bind ?entry_rooms (find-instance ((?r Room)) (eq ?r:is_entry TRUE)))
    (if (= (length$ ?entry_rooms) 0) then (return "No entry room found"))
    (bind ?entry_room (nth$ 1 ?entry_rooms))
    (return ?entry_room)
)

;;; Function to get artworks for a specific day
(deffunction Refinement::get_day_artworks (?day_num)
   (bind ?day_facts
      (find-all-facts ((?d day-artwork)) (eq ?d:num_day ?day_num)))
   (bind ?artworks (create$))
   (foreach ?f ?day_facts
      (bind ?artwork (fact-slot-value ?f artwork))
      (bind ?artworks (create$ (expand$ ?artworks) ?artwork)))
   (return ?artworks))

;;; Function to get target rooms for a list of artworks
(deffunction Refinement::get_target_rooms (?artworks)
   (bind ?target_rooms (create$))
   (foreach ?artwork ?artworks
      (bind ?room (send ?artwork get-artwork_in_room))
      (if (not (member$ ?room ?target_rooms))
         then (bind ?target_rooms (create$ (expand$ ?target_rooms) ?room))))
    (return ?target_rooms))

;;; Function to check if a multifield is a subset of another
(deffunction Refinement::is_subset (?subset ?set)
   (foreach ?item ?subset
      (if (not (member$ ?item ?set))
         then (return FALSE)))
   (return TRUE)
)

(deffunction Refinement::count-room-in-path (?room ?path)
    (bind ?count 0)
    (foreach ?r ?path
        (if (eq ?r ?room)
            then (bind ?count (+ ?count 1)))
    )
    (return ?count)
)

;;; Function to find a route for a specific day
(deffunction Refinement::find_route (?day_num ?reduced_mobility)
    (bind ?entry_room (get_entry_room))
    (bind ?artworks_today (get_day_artworks ?day_num))
    (bind ?target_rooms (get_target_rooms ?artworks_today))

    (bind ?queue (create$))

    (bind ?start_node (assert (search-node (room ?entry_room) (room_path (create$ ?entry_room)))))

    (bind ?queue (create$ ?queue ?start_node))

    (while (neq (length$ ?queue) 0)
        (bind ?current_node (nth$ 1 ?queue))
        (bind ?queue (delete$ ?queue 1 1))

        (bind ?node_room (fact-slot-value ?current_node room))
        (bind ?node_room_path (fact-slot-value ?current_node room_path))

        (if (send ?node_room get-is_exit)
            then
                (if (is_subset ?target_rooms ?node_room_path)
                    then
                    ; Delete all search facts from the facts
                    (do-for-all-facts ((?f search-node)) TRUE (retract ?f))

                    ; Return the path
                    (return ?node_room_path)
                )
        )
        (bind ?adjacent_rooms (send ?node_room get-adjacent_room))
        (foreach ?adj_room ?adjacent_rooms
            (bind ?adj_room_connections_fact_list (find-fact ((?f room-connections-count)) (eq ?f:room ?adj_room)))
            (bind ?adj_room_connections_fact (nth$ 1 ?adj_room_connections_fact_list))
            (bind ?num_connections (fact-slot-value ?adj_room_connections_fact num_connections))
            (bind ?count_room_in_path (count-room-in-path ?adj_room ?node_room_path))
            (if (< ?count_room_in_path ?num_connections)
                then
                    ;; Check for mobility
                    (bind ?is_stairs (send ?adj_room get-is_stairs))

                    (if (or (eq ?reduced_mobility FALSE) (eq ?is_stairs FALSE))
                        then
                            (bind ?new_node (assert (search-node (room ?adj_room) (room_path (create$ ?node_room_path ?adj_room)))))
                            (bind ?queue (create$ ?queue ?new_node))
                    )
            )
        )
    )
    (printout t "No route found for day " ?day_num crlf)
    (return (create$))
)


(deffunction Refinement::assign-artwork-to-day (?artwork ?artwork_time ?total_days ?daily_minutes)
    (bind ?day 1)
    (printout t "Trying to assign artwork " (send ?artwork get-artwork_name) " with time " ?artwork_time crlf)
    
    ; Assign the first day that has enough time for the artwork
    (while (<= ?day ?total_days)
        (printout t "Checking day " ?day crlf)
        (bind ?day-time-facts (find-fact ((?f day-time)) (= ?f:day ?day)))
        (bind ?day-time-fact (nth$ 1 ?day-time-facts))
        (bind ?time_sum (fact-slot-value ?day-time-fact time_sum))
        (printout t "Current time_sum for day " ?day ": " ?time_sum crlf)
        (if (<= (+ ?time_sum ?artwork_time) ?daily_minutes)
            then
            (modify ?day-time-fact (time_sum (+ ?time_sum ?artwork_time)))
            (assert (day-artwork (artwork ?artwork) (num_day ?day)))
            (printout t "Artwork assigned to day " ?day crlf)
            (return)
        )
        (bind ?day (+ ?day 1))
    )
    (printout t "No sufficient time to assign artwork on available days" crlf)
)

(defrule Refinement::distribute-artworks
	?specific-solution-fact <- (specific-solution ?specific-solution)
    (max_score (value ?match_type))
	(exists (asked-mobility))
    (not (distributed-artworks))
	=>
    (printout t "Distributing artworks among days..." crlf)
    ; Get the total days and daily minutes
    (bind ?total_days (send ?specific-solution get-total_days))
    (bind ?daily_minutes (send ?specific-solution get-daily_minutes))
    (printout t "Total days: " ?total_days ", Daily minutes: " ?daily_minutes crlf)

    ; Create day-time facts with 0 time_sum
    (bind ?day 1)
    (while (<= ?day ?total_days)
        (assert (day-time (day ?day) (time_sum 0)))
        (printout t "Initialized day " ?day " with 0 time_sum" crlf)
        (bind ?day (+ ?day 1))
    )

    ; Get the max match type value
    (bind ?ordered_match_facts (create$))
    (printout t "Max match type value: " ?match_type crlf)

    ; Order the match facts by match_type (from highest to lowest)
    (while (>= ?match_type 0)
        (bind ?current_match_facts (find-all-facts ((?f match)) (= ?f:match_type ?match_type)))
        (printout t "Found " (length$ ?current_match_facts) " matches for match type " ?match_type crlf)
        (bind ?ordered_match_facts (create$ ?ordered_match_facts ?current_match_facts))
        (bind ?match_type (- ?match_type 1))
    )

    ; Distribute artworks
    (foreach ?f ?ordered_match_facts
        (bind ?artwork (fact-slot-value ?f artwork))
        (bind ?artwork_time (fact-slot-value ?f artwork_time))
        (printout t "Assigning artwork " (send ?artwork get-artwork_name) " with time " ?artwork_time crlf)
        (assign-artwork-to-day ?artwork ?artwork_time ?total_days ?daily_minutes)
    )
	(assert (distributed-artworks))
)

;; Convert the list of rooms to a string of rooms and artworks
(deffunction Refinement::result-rooms-to-artworks (?rooms ?day)
    (bind ?result "")
    (bind ?day-artworks (find-all-facts ((?f day-artwork)) (eq ?f:num_day ?day)))
    (bind ?visited-rooms (create$))
    (foreach ?room ?rooms
        (bind ?result (str-cat ?result " --> [" ?room))
        (if (not (member$ ?room ?visited-rooms))
            then
                (bind ?any-artwork-in-room FALSE)
                (foreach ?f ?day-artworks
                    (bind ?artwork (fact-slot-value ?f artwork))
                    (bind ?artwork-room (send ?artwork get-artwork_in_room))
                    (if (eq ?artwork-room ?room)
                        then
                            (bind ?artwork_id (send ?artwork get-artwork_id))
                            (if (eq ?any-artwork-in-room FALSE)
                                then
                                (bind ?result (str-cat ?result ": " ?artwork_id))
                                (bind ?any-artwork-in-room TRUE)
                            else
                                (bind ?result (str-cat ?result ", " ?artwork_id))
                            )
                    )
                )
                (bind ?visited-rooms (create$ ?visited-rooms ?room))
        )
        (bind ?result (str-cat ?result "]"))
    )
    (return ?result)
)

;; Function to print the names of the artworks for each day
(deffunction Refinement::print-day-artworks-info (?day)
    (bind ?day-artworks (find-all-facts ((?f day-artwork)) (eq ?f:num_day ?day)))
    (foreach ?f ?day-artworks
        (bind ?artwork (fact-slot-value ?f artwork))
        (bind ?artwork_id (send ?artwork get-artwork_id))
        (bind ?artwork_name (send ?artwork get-artwork_name))
        (printout t "    - "?artwork_id ": " ?artwork_name crlf)
    )
)

(defrule Refinement::find-all-routes
	?specific-solution-fact <- (specific-solution ?specific-solution)
	(exists (distributed-artworks))
	=>
    (printout t "--------------------------------------------------------------------------------" crlf)
    (printout t "Finding all routes..." crlf)

    (bind ?reduced_mobility (send ?specific-solution get-reduced_mobility))
    (bind ?total_days (send ?specific-solution get-total_days))
    (printout t "Reduced mobility: " ?reduced_mobility ", Total days: " ?total_days crlf)

    ;; Find the route for each day
    (bind ?current_day 1)
    (bind ?start_time (time))
    (while (<= ?current_day ?total_days)
        (printout t "Finding route for day " ?current_day crlf)
        (bind ?result (find_route ?current_day ?reduced_mobility))
        (if (eq (length$ ?result) 0)
            then
            (printout t "No route found for day " ?current_day crlf)
        else
            (printout t "Route for day " ?current_day ": " (result-rooms-to-artworks ?result ?current_day) crlf)
            (bind ?day-time-facts (find-all-facts ((?f day-time)) (= ?f:day ?current_day)))
            (printout t "Total time for day " ?current_day ": " (fact-slot-value (nth$ 1 ?day-time-facts) time_sum) " minutes" crlf)
            (printout t "Artworks for day " ?current_day ":" crlf)
            (print-day-artworks-info ?current_day)
        )
        (printout t crlf)
        (bind ?current_day (+ ?current_day 1))
    )

    (bind ?end_time (time))
    (bind ?total_time (- ?end_time ?start_time))
    (printout t "--------------------------------------------------------------------------------" crlf)
    (printout t "Total time to find all routes: " ?total_time " seconds" crlf)
    (printout t "Average time per route: " (/ ?total_time ?total_days) " seconds" crlf)
)