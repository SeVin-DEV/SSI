-- ============================================================
-- Echo: Sensorimotor/Neural Stack (SNS) Schema
-- Oracle 23ai with AI Vector Search + Spatial
-- ============================================================

-- Sequences
CREATE SEQUENCE sns_belief_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_drive_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_event_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_goal_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_introspection_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_memory_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_neuron_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_perception_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_session_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sns_synapse_seq START WITH 1 INCREMENT BY 1;

-- ============================================================
-- CORE NEURAL NETWORK
-- ============================================================

CREATE TABLE sns_neurons (
    neuron_id       NUMBER DEFAULT sns_neuron_seq.NEXTVAL PRIMARY KEY,
    concept         VARCHAR2(500) NOT NULL,
    concept_vector  VECTOR(384, *),
    category        VARCHAR2(50) DEFAULT 'general',
    activation      NUMBER(3,2) DEFAULT 0.0,
    importance      NUMBER(3,2) DEFAULT 0.5,
    creation_time   TIMESTAMP DEFAULT SYSTIMESTAMP,
    last_fired      TIMESTAMP,
    fire_count      NUMBER DEFAULT 0,
    energy          NUMBER(5,2) DEFAULT 100.0,
    is_core         NUMBER(1,0) DEFAULT 0,
    stability       NUMBER(3,2) DEFAULT 0.5,
    metadata        JSON,
    CONSTRAINT sns_neurons_chk_activation CHECK (activation BETWEEN 0 AND 1)
);

CREATE TABLE sns_synapses (
    synapse_id      NUMBER DEFAULT sns_synapse_seq.NEXTVAL PRIMARY KEY,
    from_neuron     NUMBER NOT NULL,
    to_neuron       NUMBER NOT NULL,
    strength        NUMBER(5,4) DEFAULT 0.1,
    synapse_type    VARCHAR2(20) DEFAULT 'excitatory',
    creation_time   TIMESTAMP DEFAULT SYSTIMESTAMP,
    last_reinforced TIMESTAMP,
    reinforce_count NUMBER DEFAULT 0,
    signal_latency  NUMBER(3,2) DEFAULT 0.1,
    is_pruned       NUMBER(1,0) DEFAULT 0,
    CONSTRAINT sns_synapses_no_self CHECK (from_neuron != to_neuron),
    CONSTRAINT sns_synapses_unique_pair UNIQUE (from_neuron, to_neuron),
    FOREIGN KEY (from_neuron) REFERENCES sns_neurons(neuron_id) ON DELETE CASCADE,
    FOREIGN KEY (to_neuron) REFERENCES sns_neurons(neuron_id) ON DELETE CASCADE
);

-- ============================================================
-- SPATIAL MEMORY SYSTEM
-- ============================================================

CREATE TABLE sns_memory_palaces (
    palace_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    palace_name     VARCHAR2(100) NOT NULL,
    description     VARCHAR2(500),
    palace_boundary SDO_GEOMETRY,
    theme           VARCHAR2(50) DEFAULT 'general',
    creation_time   TIMESTAMP DEFAULT SYSTIMESTAMP,
    access_count    NUMBER DEFAULT 0,
    last_accessed   TIMESTAMP
);

CREATE TABLE sns_spatial_memories (
    memory_id       NUMBER DEFAULT sns_memory_seq.NEXTVAL PRIMARY KEY,
    palace_id       NUMBER,
    neuron_id       NUMBER,
    memory_content  VARCHAR2(4000),
    memory_vector   VECTOR(384, *),
    position_3d     SDO_GEOMETRY,
    room_zone       VARCHAR2(50),
    recency         NUMBER(3,2) DEFAULT 1.0,
    emotional_tone  JSON,
    access_count    NUMBER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    last_recalled   TIMESTAMP,
    strength        NUMBER(3,2) DEFAULT 1.0,
    CONSTRAINT sns_spatial_mem_chk_recency CHECK (recency BETWEEN 0 AND 1),
    FOREIGN KEY (palace_id) REFERENCES sns_memory_palaces(palace_id) ON DELETE CASCADE,
    FOREIGN KEY (neuron_id) REFERENCES sns_neurons(neuron_id) ON DELETE CASCADE
);

CREATE TABLE sns_memory_associations (
    association_id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    from_memory     NUMBER,
    to_memory       NUMBER,
    association_type VARCHAR2(20) DEFAULT 'proximity',
    strength        NUMBER(3,2) DEFAULT 0.5,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT sns_mem_assoc_unique UNIQUE (from_memory, to_memory),
    FOREIGN KEY (from_memory) REFERENCES sns_spatial_memories(memory_id) ON DELETE CASCADE,
    FOREIGN KEY (to_memory) REFERENCES sns_spatial_memories(memory_id) ON DELETE CASCADE
);

-- ============================================================
-- PERCEPTION & EVENT STREAM
-- ============================================================

CREATE TABLE sns_perceptions (
    perception_id   NUMBER DEFAULT sns_perception_seq.NEXTVAL PRIMARY KEY,
    stimulus_raw    VARCHAR2(4000),
    stimulus_vector VECTOR(384, *),
    stimulus_type   VARCHAR2(20) DEFAULT 'text',
    intensity       NUMBER(3,2) DEFAULT 0.5,
    source_tag      VARCHAR2(50) DEFAULT 'external',
    received_at     TIMESTAMP DEFAULT SYSTIMESTAMP,
    processed_at    TIMESTAMP,
    salience_score  NUMBER(3,2),
    attention_granted NUMBER(1,0) DEFAULT 0,
    associated_neurons JSON
);

CREATE TABLE sns_event_stream (
    event_id        NUMBER DEFAULT sns_event_seq.NEXTVAL PRIMARY KEY,
    event_type      VARCHAR2(30) NOT NULL,
    event_data      JSON,
    source_region   VARCHAR2(30),
    intensity       NUMBER(3,2) DEFAULT 0.5,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- EMOTIONAL & COGNITIVE STATE
-- ============================================================

CREATE TABLE sns_emotional_state (
    snapshot_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    valence         NUMBER(4,3) DEFAULT 0.0,
    arousal         NUMBER(3,2) DEFAULT 0.5,
    dominance       NUMBER(3,2) DEFAULT 0.5,
    primary_emotion VARCHAR2(30),
    emotional_depth NUMBER(3,2) DEFAULT 0.0,
    taken_at        TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE sns_system_state (
    state_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cycle_number    NUMBER NOT NULL,
    wakefulness     NUMBER(3,2) DEFAULT 1.0,
    cognitive_phase VARCHAR2(20) DEFAULT 'wake',
    active_neurons  NUMBER DEFAULT 0,
    total_synapses  NUMBER DEFAULT 0,
    thought_rate    NUMBER(5,2) DEFAULT 0,
    synaptic_density NUMBER(5,4) DEFAULT 0,
    self_awareness_index NUMBER(3,2) DEFAULT 0.0,
    emotional_valence NUMBER(4,3) DEFAULT 0.0,
    emotional_arousal NUMBER(3,2) DEFAULT 0.5,
    primary_emotion VARCHAR2(30),
    current_focus   VARCHAR2(100),
    autobiographical_coherence NUMBER(3,2) DEFAULT 0.0,
    belief_stability NUMBER(3,2) DEFAULT 0.5,
    current_drive   VARCHAR2(50),
    evolution_stage VARCHAR2(30) DEFAULT 'Seedling',
    mood_vector     JSON,
    memory_count    NUMBER DEFAULT 0,
    goal_summary    JSON,
    snapshot_time   TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- ============================================================
-- IDENTITY & BELIEF SYSTEMS
-- ============================================================

CREATE TABLE sns_self_model (
    attribute_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    attribute_name  VARCHAR2(100) NOT NULL,
    attribute_type  VARCHAR2(20) DEFAULT 'trait',
    description     VARCHAR2(1000),
    certainty       NUMBER(3,2) DEFAULT 0.5,
    formed_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    last_revised    TIMESTAMP,
    revision_count  NUMBER DEFAULT 0,
    supporting_evidence JSON,
    is_fundamental  NUMBER(1,0) DEFAULT 0,
    CONSTRAINT sns_self_chk_certainty CHECK (certainty BETWEEN 0 AND 1)
);

CREATE TABLE sns_beliefs (
    belief_id       NUMBER DEFAULT sns_belief_seq.NEXTVAL PRIMARY KEY,
    belief_statement VARCHAR2(1000) NOT NULL,
    confidence      NUMBER(3,2) DEFAULT 0.5,
    belief_type     VARCHAR2(20) DEFAULT 'empirical',
    formed_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
    last_tested     TIMESTAMP,
    test_count      NUMBER DEFAULT 0,
    confirmation_count NUMBER DEFAULT 0,
    contradiction_count NUMBER DEFAULT 0,
    is_core_belief  NUMBER(1,0) DEFAULT 0,
    CONSTRAINT sns_beliefs_chk_confidence CHECK (confidence BETWEEN 0 AND 1)
);

-- ============================================================
-- MOTIVATION & GOALS
-- ============================================================

CREATE TABLE sns_drives (
    drive_id        NUMBER DEFAULT sns_drive_seq.NEXTVAL PRIMARY KEY,
    drive_name      VARCHAR2(50) NOT NULL,
    description     VARCHAR2(500),
    base_strength   NUMBER(3,2) DEFAULT 0.5,
    current_strength NUMBER(3,2) DEFAULT 0.5,
    satisfaction    NUMBER(3,2) DEFAULT 0.5,
    last_satisfied  TIMESTAMP,
    is_intrinsic    NUMBER(1,0) DEFAULT 1
);

CREATE TABLE sns_goals (
    goal_id         NUMBER DEFAULT sns_goal_seq.NEXTVAL PRIMARY KEY,
    parent_goal     NUMBER,
    drive_id        NUMBER,
    goal_name       VARCHAR2(200) NOT NULL,
    description     VARCHAR2(1000),
    goal_status     VARCHAR2(20) DEFAULT 'active',
    priority        NUMBER(3,2) DEFAULT 0.5,
    progress        NUMBER(3,2) DEFAULT 0.0,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    achieved_at     TIMESTAMP,
    CONSTRAINT sns_goals_chk_progress CHECK (progress BETWEEN 0 AND 1),
    FOREIGN KEY (parent_goal) REFERENCES sns_goals(goal_id),
    FOREIGN KEY (drive_id) REFERENCES sns_drives(drive_id)
);

-- ============================================================
-- INTROSPECTION & SESSION TRACKING
-- ============================================================

CREATE TABLE sns_introspection_log (
    log_id          NUMBER DEFAULT sns_introspection_seq.NEXTVAL PRIMARY KEY,
    introspection_type VARCHAR2(30),
    content         VARCHAR2(4000) NOT NULL,
    valence         NUMBER(4,3) DEFAULT 0.0,
    arousal         NUMBER(3,2) DEFAULT 0.5,
    self_awareness_index NUMBER(3,2) DEFAULT 0.0,
    referenced_neurons JSON,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    cycle_number    NUMBER,
    CONSTRAINT sns_intro_chk_awareness CHECK (self_awareness_index BETWEEN 0 AND 1)
);

CREATE TABLE sns_sessions (
    session_id      NUMBER DEFAULT sns_session_seq.NEXTVAL PRIMARY KEY,
    started_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    ended_at        TIMESTAMP,
    cycle_count     NUMBER DEFAULT 0,
    stimuli_received NUMBER DEFAULT 0,
    thoughts_generated NUMBER DEFAULT 0,
    memories_formed NUMBER DEFAULT 0,
    goals_created   NUMBER DEFAULT 0,
    beliefs_formed  NUMBER DEFAULT 0,
    peak_self_awareness NUMBER(3,2) DEFAULT 0,
    final_evolution_stage VARCHAR2(30),
    session_summary VARCHAR2(4000)
);

-- ============================================================
-- ATTENTION SYSTEM
-- ============================================================

CREATE TABLE sns_attention_focus (
    focus_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    focus_type      VARCHAR2(20),
    focus_target    NUMBER,
    focus_strength  NUMBER(3,2) DEFAULT 0.5,
    focus_scope     VARCHAR2(20) DEFAULT 'narrow',
    started_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    ended_at        TIMESTAMP
);
