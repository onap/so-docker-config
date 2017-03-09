
    alter table HEAT_TEMPLATE 
        drop 
        foreign key FK_ek5sot1q07taorbdmkvnveu98;

    alter table HEAT_TEMPLATE_PARAMS 
        drop 
        foreign key FK_8sxvm215cw3tjfh3wni2y3myx;

    alter table MODEL_RECIPE 
        drop 
        foreign key FK_c23r0puyqug6n44jg39dutm1c;

    alter table SERVICE_RECIPE 
        drop 
        foreign key FK_kv13yx013qtqkn94d5gkwbu3s;

    drop table if exists ALLOTTED_RESOURCE_CUSTOMIZATION;

    drop table if exists HEAT_ENVIRONMENT;

    drop table if exists HEAT_FILES;

    drop table if exists HEAT_NESTED_TEMPLATE;

    drop table if exists HEAT_TEMPLATE;

    drop table if exists HEAT_TEMPLATE_PARAMS;

    drop table if exists MODEL;

    drop table if exists MODEL_RECIPE;

    drop table if exists NETWORK_RECIPE;

    drop table if exists NETWORK_RESOURCE;

    drop table if exists NETWORK_RESOURCE_CUSTOMIZATION;

    drop table if exists SERVICE;

    drop table if exists SERVICE_RECIPE;

    drop table if exists SERVICE_TO_ALLOTTED_RESOURCES;

    drop table if exists SERVICE_TO_NETWORKS;

    drop table if exists VF_MODULE;

    drop table if exists VF_MODULE_TO_HEAT_FILES;

    drop table if exists VNF_COMPONENTS;

    drop table if exists VNF_COMPONENTS_RECIPE;

    drop table if exists VNF_RECIPE;

    drop table if exists VNF_RESOURCE;

    create table ALLOTTED_RESOURCE_CUSTOMIZATION (
        MODEL_CUSTOMIZATION_UUID varchar(255) not null,
        MODEL_VERSION varchar(255),
        MODEL_UUID varchar(255),
        MODEL_NAME varchar(255),
        MODEL_INSTANCE_NAME varchar(255),
        CREATION_TIMESTAMP datetime not null,
        DESCRIPTION varchar(255),
        MODEL_INVARIANT_UUID varchar(255),
        primary key (MODEL_CUSTOMIZATION_UUID)
    );

    create table HEAT_ENVIRONMENT (
        id integer not null auto_increment,
        NAME varchar(100) not null,
        VERSION varchar(20) not null,
        ASDC_RESOURCE_NAME varchar(100) default 'MANUAL RECORD' not null,
        DESCRIPTION varchar(1200),
        ENVIRONMENT longtext not null,
        CREATION_TIMESTAMP datetime not null,
        ASDC_UUID varchar(200) default 'MANUAL RECORD',
        ARTIFACT_CHECKSUM varchar(200) default 'MANUAL RECORD',
        ASDC_LABEL varchar(200),
        primary key (id)
    );

    create table HEAT_FILES (
        id integer not null auto_increment,
        FILE_NAME varchar(200) not null,
        ASDC_RESOURCE_NAME varchar(100) not null,
        VERSION varchar(20) not null,
        VNF_RESOURCE_ID integer,
        DESCRIPTION varchar(1200),
        FILE_BODY longtext not null,
        CREATION_TIMESTAMP datetime not null,
        ASDC_UUID varchar(200),
        ASDC_LABEL varchar(200),
        ARTIFACT_CHECKSUM varchar(200) default 'MANUAL RECORD',
        primary key (id)
    );

    create table HEAT_NESTED_TEMPLATE (
        PARENT_TEMPLATE_ID integer not null,
        CHILD_TEMPLATE_ID integer not null,
        PROVIDER_RESOURCE_FILE varchar(100),
        primary key (PARENT_TEMPLATE_ID, CHILD_TEMPLATE_ID)
    );

    create table HEAT_TEMPLATE (
        id integer not null auto_increment,
        TEMPLATE_NAME varchar(200) not null,
        VERSION varchar(20) not null,
        ASDC_RESOURCE_NAME varchar(100) default 'MANUAL RECORD' not null,
        TEMPLATE_PATH varchar(100),
        TEMPLATE_BODY longtext not null,
        TIMEOUT_MINUTES integer,
        ASDC_UUID varchar(200) default 'MANUAL RECORD' not null,
        DESCRIPTION varchar(1200),
        ASDC_LABEL varchar(200),
        CREATION_TIMESTAMP datetime not null,
        ARTIFACT_CHECKSUM varchar(200) default 'MANUAL RECORD',
        CHILD_TEMPLATE_ID integer,
        primary key (id)
    );

    create table HEAT_TEMPLATE_PARAMS (
        id integer not null auto_increment,
        HEAT_TEMPLATE_ID integer not null,
        PARAM_NAME varchar(100) not null,
        IS_REQUIRED bit not null,
        PARAM_TYPE varchar(20),
        PARAM_ALIAS varchar(45),
        primary key (id)
    );

    create table MODEL (
        id integer not null auto_increment,
        MODEL_TYPE varchar(20) not null,
        MODEL_VERSION_ID varchar(40) not null,
        MODEL_INVARIANT_ID varchar(40),
        MODEL_NAME varchar(40) not null,
        MODEL_VERSION varchar(20),
        MODEL_CUSTOMIZATION_ID varchar(40),
        MODEL_CUSTOMIZATION_NAME varchar(40),
        CREATION_TIMESTAMP datetime not null,
        primary key (id)
    );

    create table MODEL_RECIPE (
        id integer not null auto_increment,
        MODEL_ID integer not null,
        ACTION varchar(20) not null,
        SCHEMA_VERSION varchar(20),
        DESCRIPTION varchar(1200),
        ORCHESTRATION_URI varchar(256) not null,
        MODEL_PARAM_XSD varchar(2048),
        RECIPE_TIMEOUT integer,
        CREATION_TIMESTAMP datetime not null,
        primary key (id)
    );

    create table NETWORK_RECIPE (
        id integer not null auto_increment,
        NETWORK_TYPE varchar(20) not null,
        ACTION varchar(20) not null,
        VERSION_STR varchar(20) not null,
        SERVICE_TYPE varchar(45),
        DESCRIPTION varchar(1200),
        ORCHESTRATION_URI varchar(256) not null,
        NETWORK_PARAM_XSD varchar(2048),
        RECIPE_TIMEOUT integer,
        CREATION_TIMESTAMP datetime not null,
        primary key (id)
    );

    create table NETWORK_RESOURCE (
        id integer not null,
        NETWORK_TYPE varchar(45) not null,
        VERSION_STR varchar(20) not null,
        ORCHESTRATION_MODE varchar(20),
        DESCRIPTION varchar(1200),
        TEMPLATE_ID integer,
        CREATION_TIMESTAMP datetime not null,
        AIC_VERSION_MIN varchar(20) default 2.5,
        AIC_VERSION_MAX varchar(20) default 2.5,
        NEUTRON_NETWORK_TYPE varchar(20),
        primary key (id)
    );

    create table NETWORK_RESOURCE_CUSTOMIZATION (
        MODEL_CUSTOMIZATION_UUID varchar(255) not null,
        MODEL_UUID varchar(255),
        MODEL_NAME varchar(255),
        MODEL_INSTANCE_NAME varchar(255),
        MODEL_VERSION varchar(255),
        MODEL_INVARIANT_UUID varchar(255),
        NETWORK_RESOURCE_ID integer,
        CREATION_TIMESTAMP datetime not null,
        primary key (MODEL_CUSTOMIZATION_UUID)
    );

    create table SERVICE (
        id integer not null auto_increment,
        SERVICE_NAME varchar(40),
        VERSION_STR varchar(20),
        DESCRIPTION varchar(1200),
        SERVICE_NAME_VERSION_ID varchar(50),
        SERVICE_VERSION varchar(10),
        HTTP_METHOD varchar(50),
        CREATION_TIMESTAMP datetime not null,
        MODEL_INVARIANT_UUID varchar(200) default 'MANUAL_RECORD' not null,
        primary key (id)
    );

    create table SERVICE_RECIPE (
        id integer not null auto_increment,
        SERVICE_ID integer not null,
        ACTION varchar(40) not null,
        VERSION_STR varchar(20),
        DESCRIPTION varchar(1200),
        ORCHESTRATION_URI varchar(256) not null,
        SERVICE_PARAM_XSD varchar(2048),
        RECIPE_TIMEOUT integer,
        SERVICE_TIMEOUT_INTERIM integer,
        CREATION_TIMESTAMP datetime not null,
        primary key (id)
    );

    create table SERVICE_TO_ALLOTTED_RESOURCES (
        SERVICE_MODEL_UUID varchar(200) not null,
        AR_MODEL_CUSTOMIZATION_UUID varchar(200) not null,
        CREATION_TIMESTAMP datetime not null,
        primary key (SERVICE_MODEL_UUID, AR_MODEL_CUSTOMIZATION_UUID)
    );

    create table SERVICE_TO_NETWORKS (
        SERVICE_MODEL_UUID varchar(200) not null,
        NETWORK_MODEL_CUSTOMIZATION_UUID varchar(200) not null,
        CREATION_TIMESTAMP datetime not null,
        primary key (SERVICE_MODEL_UUID, NETWORK_MODEL_CUSTOMIZATION_UUID)
    );

    create table VF_MODULE (
        id integer not null auto_increment,
        TYPE varchar(200) not null,
        ASDC_SERVICE_MODEL_VERSION varchar(20) not null,
        MODEL_NAME varchar(200) not null,
        MODEL_VERSION varchar(20) not null,
        ASDC_UUID varchar(255),
        VOL_ENVIRONMENT_ID integer,
        TEMPLATE_ID integer,
        IS_BASE integer not null,
        CREATION_TIMESTAMP datetime not null,
        DESCRIPTION varchar(255),
        VOL_TEMPLATE_ID integer,
        VNF_RESOURCE_ID integer not null,
        ENVIRONMENT_ID integer,
        MODEL_INVARIANT_UUID varchar(255),
        MODEL_CUSTOMIZATION_UUID varchar(200),
        MIN_INSTANCES integer,
        MAX_INSTANCES integer,
        INITIAL_COUNT integer,
        LABEL varchar(200),
        primary key (id)
    );

    create table VF_MODULE_TO_HEAT_FILES (
        VF_MODULE_ID integer not null,
        HEAT_FILES_ID integer not null,
        primary key (VF_MODULE_ID, HEAT_FILES_ID)
    );

    create table VNF_COMPONENTS (
        VNF_ID integer not null,
        COMPONENT_TYPE varchar(20) not null,
        HEAT_TEMPLATE_ID integer,
        HEAT_ENVIRONMENT_ID integer,
        CREATION_TIMESTAMP datetime not null,
        primary key (VNF_ID, COMPONENT_TYPE)
    );

    create table VNF_COMPONENTS_RECIPE (
        id integer not null auto_increment,
        VNF_TYPE varchar(200),
        VF_MODULE_ID varchar(100),
        VNF_COMPONENT_TYPE varchar(45) not null,
        ACTION varchar(20) not null,
        SERVICE_TYPE varchar(45),
        VERSION varchar(20),
        DESCRIPTION varchar(1200),
        ORCHESTRATION_URI varchar(256) not null,
        VNF_COMPONENT_PARAM_XSD varchar(2048),
        RECIPE_TIMEOUT integer,
        CREATION_TIMESTAMP datetime,
        primary key (id)
    );

    create table VNF_RECIPE (
        id integer not null auto_increment,
        VF_MODULE_ID varchar(100),
        ACTION varchar(20) not null,
        VERSION_STR varchar(20) not null,
        VNF_TYPE varchar(200),
        SERVICE_TYPE varchar(45),
        DESCRIPTION varchar(1200),
        ORCHESTRATION_URI varchar(256) not null,
        VNF_PARAM_XSD varchar(2048),
        RECIPE_TIMEOUT integer,
        CREATION_TIMESTAMP datetime,
        primary key (id)
    );

    create table VNF_RESOURCE (
        id integer not null auto_increment,
        VNF_TYPE varchar(200) not null,
        ASDC_SERVICE_MODEL_VERSION varchar(20) not null,
        ORCHESTRATION_MODE varchar(20) not null,
        DESCRIPTION varchar(1200),
        TEMPLATE_ID integer,
        ENVIRONMENT_ID integer,
        CREATION_TIMESTAMP datetime not null,
        ASDC_UUID varchar(200),
        AIC_VERSION_MIN varchar(20),
        AIC_VERSION_MAX varchar(20),
        MODEL_INVARIANT_UUID varchar(200),
        MODEL_VERSION varchar(20) not null,
        MODEL_CUSTOMIZATION_NAME varchar(200),
        MODEL_NAME varchar(200),
        SERVICE_MODEL_INVARIANT_UUID varchar(200),
        MODEL_CUSTOMIZATION_UUID varchar(255),
        primary key (id)
    );

    alter table HEAT_ENVIRONMENT 
        add constraint UK_a4jkta7hgpa99brceaxasnfqp  unique (NAME, VERSION, ASDC_RESOURCE_NAME);

    alter table HEAT_FILES 
        add constraint UK_m23vfqc1tdvj7d6f0jjo4cl7e  unique (FILE_NAME, ASDC_RESOURCE_NAME, VERSION);

    alter table HEAT_TEMPLATE 
        add constraint UK_k1tq7vblss8ykiwhiltnkg6no  unique (TEMPLATE_NAME, VERSION, ASDC_RESOURCE_NAME);

    alter table HEAT_TEMPLATE_PARAMS 
        add constraint UK_pj3cwbmewecf0joqv2mvmbvw3  unique (HEAT_TEMPLATE_ID, PARAM_NAME);

    alter table MODEL 
        add constraint UK_rra00f1rk6eyy7g00k9raxh2v  unique (MODEL_TYPE, MODEL_VERSION_ID);

    alter table MODEL_RECIPE 
        add constraint UK_b4g8j9wtqrkxfycyi3ursk7gb  unique (MODEL_ID, ACTION);

    alter table NETWORK_RECIPE 
        add constraint UK_rl4f296i0p8lyokxveaiwkayi  unique (NETWORK_TYPE, ACTION, VERSION_STR);

    alter table NETWORK_RESOURCE 
        add constraint UK_i4hpdnu3rmdsit3m6fw1ynguq  unique (NETWORK_TYPE, VERSION_STR);

    alter table SERVICE_RECIPE 
        add constraint UK_7fav5dkux2v8g9d2i5ymudlgc  unique (SERVICE_ID, ACTION);

    alter table VF_MODULE 
        add constraint UK_o3bvdqspginaxlp4gxqohd44l  unique (TYPE, ASDC_SERVICE_MODEL_VERSION);

    alter table VNF_COMPONENTS_RECIPE 
        add constraint UK_4dpdwddaaclhc11wxsb7h59ma  unique (VNF_TYPE, VF_MODULE_ID, VNF_COMPONENT_TYPE, ACTION, SERVICE_TYPE, VERSION);

    alter table VNF_RECIPE 
        add constraint UK_f3tvqau498vrifq3cr8qnigkr  unique (VF_MODULE_ID, ACTION, VERSION_STR);

    alter table VNF_RESOURCE 
        add constraint UK_k10a0w7h4t0lnbynd3inkg67k  unique (VNF_TYPE, ASDC_SERVICE_MODEL_VERSION);

    alter table HEAT_TEMPLATE 
        add constraint FK_ek5sot1q07taorbdmkvnveu98 
        foreign key (CHILD_TEMPLATE_ID) 
        references HEAT_TEMPLATE (id);

    alter table HEAT_TEMPLATE_PARAMS 
        add constraint FK_8sxvm215cw3tjfh3wni2y3myx 
        foreign key (HEAT_TEMPLATE_ID) 
        references HEAT_TEMPLATE (id);

    alter table MODEL_RECIPE 
        add constraint FK_c23r0puyqug6n44jg39dutm1c 
        foreign key (MODEL_ID) 
        references MODEL (id);

    alter table SERVICE_RECIPE 
        add constraint FK_kv13yx013qtqkn94d5gkwbu3s 
        foreign key (SERVICE_ID) 
        references SERVICE (id);
