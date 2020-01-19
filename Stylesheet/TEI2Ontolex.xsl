<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="1.0" xmlns="http://lari-datasets.ilc.cnr.it/nenu_sample#"
    xml:base="http://lari-datasets.ilc.cnr.it/nenu_sample" xmlns:void="http://rdfs.org/ns/void#"
    xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:ns="http://creativecommons.org/ns#"
    xmlns:lime="http://www.w3.org/ns/lemon/lime" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:lexinfo="http://www.lexinfo.net/ontology/2.0/lexinfo#"
    xmlns:lexicog="http://www.w3.org/ns/lemon/lexicog#" xmlns:dct="http://purl.org/dc/terms/"
    xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:terms="http://purl.org/dc/terms/" xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:ontolex="http://www.w3.org/ns/lemon/ontolex#" xmlns:vann="http://purl.org/vocab/vann/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:lime1="http://www.w3.org/ns/lemon/lime#"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:skos="http://www.w3.org/2004/02/skos/core#">

    <xsl:variable name="LexiconURI" select="'http://www.mylexica.perso/PLI1906'"/>

    <xsl:output indent="yes" method="xml"/>

    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates select="descendant::tei:entry"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="tei:entry">
        <xsl:choose>
            <xsl:when test="tei:gramGrp/tei:pos/@expand = 'locution'">
                <owl:NamedIndividual rdf:about="{$LexiconURI}#{@xml:id}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/lemon/ontolex#MultiwordExpression"/>
                    <xsl:apply-templates/>
                </owl:NamedIndividual>
            </xsl:when>
            <xsl:otherwise>
                <ontolex:LexicalEntry rdf:ID="{@xml:id}">
                    <xsl:apply-templates/>
                </ontolex:LexicalEntry>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:entry/tei:form[@type = 'lemma'] | tei:entry/tei:form[not(@type)]">
        <ontolex:canonicalForm>
            <rdf:Description>
                <xsl:apply-templates/>
            </rdf:Description>
        </ontolex:canonicalForm>
    </xsl:template>
    
    <xsl:template match="tei:entry/tei:form[@type = 'inflected']">
        <ontolex:otherForm>
            <rdf:Description>
                <xsl:apply-templates/>
            </rdf:Description>
        </ontolex:otherForm>
    </xsl:template>
    

    <xsl:template match="tei:orth">
        <xsl:variable name="workingLanguage" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        <ontolex:writtenRep xml:lang="{$workingLanguage}">
            <xsl:apply-templates/>
        </ontolex:writtenRep>
    </xsl:template>

    <xsl:template match="tei:orth/tei:seg | tei:orth/tei:pc">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:pron">
        <xsl:variable name="workingLanguage" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        <xsl:variable name="languageWithNotation">
            <xsl:choose>
                <xsl:when test="@notation">
                    <xsl:value-of select="concat($workingLanguage, '-fon', @notation)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$workingLanguage"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <ontolex:phoneticRep xml:lang="{$languageWithNotation}">
            <xsl:apply-templates/>
        </ontolex:phoneticRep>
    </xsl:template>

    <xsl:template match="tei:pron/tei:seg | tei:pron/tei:pc">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template
        match="tei:form/text() | tei:orth/text()[normalize-space() = ''] | tei:pron/text()[normalize-space() = '']"/>

    <xsl:template match="tei:form[@type = 'lemma']/tei:form[@type = 'variant']">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:gramGrp">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:pos | tei:gram[@type = 'pos']">
        <xsl:if test="not(@expan = 'locution')">
            <xsl:variable name="sourceReference">
                <xsl:choose>
                    <xsl:when test="@norm">
                        <xsl:value-of select="@norm"/>
                    </xsl:when>
                    <xsl:when test="@expand">
                        <xsl:value-of select="@expand"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="lexinfoCategory">
                <xsl:choose>
                    <xsl:when test="$sourceReference = 'nom' or $sourceReference = 'noun' or $sourceReference = 'NOUN'">Noun</xsl:when>
                    <xsl:when test="@expand = 'préposition'">Preposition</xsl:when>
                    <xsl:when
                        test="$sourceReference = 'adjectif' or $sourceReference = 'adjective' or $sourceReference = 'ADJ'"
                        >Adjective</xsl:when>
                    <xsl:when test="@expand = 'verbe'">Verb</xsl:when>
                    <xsl:when
                        test="$sourceReference = 'adverbe' or $sourceReference = 'adverb' or $sourceReference = 'ADV'"
                        >Adverb</xsl:when>
                    <xsl:when test="$sourceReference = 'pronom' or $sourceReference = 'pronoun' or $sourceReference = 'PRON'">Pronoun</xsl:when>
                    <xsl:when test="$sourceReference = 'article' or $sourceReference = 'determiner' or $sourceReference = 'DET'">Determiner</xsl:when>
                    <xsl:when test="$sourceReference = 'interjection' or $sourceReference = 'INTJ'">Interjection</xsl:when>
                    <xsl:when test="$sourceReference = 'nombre' or $sourceReference = 'number' or $sourceReference = 'NUM'">Number</xsl:when>
                    <xsl:when test="$sourceReference = 'particule' or $sourceReference = 'particle' or $sourceReference = 'PART'">Particle</xsl:when>
                    
                    <xsl:when test="@expand = 'préfixe'">Prefix</xsl:when>
                    <xsl:when
                        test="$sourceReference = 'conjonction de coordination' or $sourceReference = 'coordinating conjunction' or $sourceReference = 'CCONJ'"
                        >CoordinatingConjunction</xsl:when>
                    <xsl:when
                        test="$sourceReference = 'auxiliaire' or $sourceReference = 'auxiliary' or $sourceReference = 'AUX'"
                        >Auxiliary</xsl:when>
                    <xsl:when
                        test="$sourceReference = 'préposition' or $sourceReference = 'preposition' or $sourceReference = 'ADP'"
                        >Preposition</xsl:when>
                    <xsl:otherwise>
                        <xsl:message>CategoryRemainsToBeDetermined: <xsl:value-of select="$sourceReference"
                            /></xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <lexinfo:partOfSpeech rdf:resource="http://www.lexinfo.net/ontology/2.0/lexinfo#{$lexinfoCategory}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:gen | tei:gram[@type = 'gen']">
        <xsl:variable name="sourceReference">
            <xsl:choose>
                <xsl:when test="@norm">
                    <xsl:value-of select="@norm"/>
                </xsl:when>
                <xsl:when test="@expand">
                    <xsl:value-of select="@expand"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lexinfoGender">
            <xsl:choose>
                <xsl:when test="$sourceReference = 'masculin' or $sourceReference = 'masculine'">masculine</xsl:when>
                <xsl:when test="$sourceReference = 'féminin' or $sourceReference = 'feminine'">feminine</xsl:when>
                <xsl:when test="$sourceReference = 'neutre' or $sourceReference = 'neuter'">neuter</xsl:when>
                <xsl:otherwise>GenderValueRemainsToBeDetermined for: <xsl:value-of select="$sourceReference"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>Gender transformation from <xsl:value-of select="$sourceReference"/> to <xsl:value-of
                select="$lexinfoGender"/></xsl:message>
        <lexinfo:gender rdf:resource="http://www.lexinfo.net/ontology/2.0/lexinfo#{$lexinfoGender}"/>
    </xsl:template>
    
    
    <xsl:template match="tei:number | tei:gram[@type = 'num'] | tei:gram[@type = 'number']">
        <xsl:variable name="sourceReference">
            <xsl:choose>
                <xsl:when test="@norm">
                    <xsl:value-of select="@norm"/>
                </xsl:when>
                <xsl:when test="@expand">
                    <xsl:value-of select="@expand"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lexinfoNumber">
            <xsl:choose>
                <xsl:when test="$sourceReference = 'singulier' or $sourceReference = 'singular'">singular</xsl:when>
                <xsl:when test="$sourceReference = 'pluriel' or $sourceReference = 'plural'">plural</xsl:when>
                <xsl:when test="$sourceReference = 'dual'">dual</xsl:when>
                <xsl:otherwise>GenderValueRemainsToBeDetermined for: <xsl:value-of select="$sourceReference"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>Number transformation from <xsl:value-of select="$sourceReference"/> to <xsl:value-of
            select="$lexinfoNumber"/></xsl:message>
        <lexinfo:number rdf:resource="http://www.lexinfo.net/ontology/2.0/lexinfo#{$lexinfoNumber}"/>
    </xsl:template>
    
    <xsl:template match="tei:tns | tei:gram[@type = 'tns'] | tei:gram[@type = 'tense']">
        <xsl:variable name="sourceReference">
            <xsl:choose>
                <xsl:when test="@norm">
                    <xsl:value-of select="@norm"/>
                </xsl:when>
                <xsl:when test="@expand">
                    <xsl:value-of select="@expand"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lexinfoTense">
            <xsl:choose>
                <xsl:when test="$sourceReference = 'présent' or $sourceReference = 'present'">present</xsl:when>
                <xsl:when test="$sourceReference = 'futur' or $sourceReference = 'future'">future</xsl:when>
                <xsl:when test="$sourceReference = 'passé' or $sourceReference = 'past'">past</xsl:when>
                <xsl:when test="$sourceReference = 'prétérite' or $sourceReference = 'preterite'">preterite</xsl:when>
                <xsl:otherwise>TenseValueRemainsToBeDetermined for: <xsl:value-of select="$sourceReference"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>Tense transformation from <xsl:value-of select="$sourceReference"/> to <xsl:value-of
            select="$lexinfoTense"/></xsl:message>
        <lexinfo:tense rdf:resource="http://www.lexinfo.net/ontology/2.0/lexinfo#{$lexinfoTense}"/>
    </xsl:template>


    <!-- Punctuations are not kept in Ontolex -->

    <xsl:template match="tei:pc"/>

    <!-- Sense related transformation in two ways: a) reference within an entry and b) creation of the actual LexicalSense node -->

    <xsl:template match="tei:sense">
        <ontolex:sense>
            <rdf:Description>
                <xsl:apply-templates/>
            </rdf:Description>
        </ontolex:sense>
    </xsl:template>

    <xsl:template match="tei:usg">
        <lexinfo:register>
            <rdf:Description>
                <xsl:apply-templates/>
            </rdf:Description>
        </lexinfo:register>
    </xsl:template>

    <xsl:template match="tei:def">
        <xsl:variable name="workingLanguage" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        <skos:definition xml:lang="{$workingLanguage}">
            <xsl:apply-templates/>
        </skos:definition>
    </xsl:template>

    <xsl:template match="tei:cit[@type = 'example' or @type = 'quote']">
        <lexicog:usageExample>
            <xsl:apply-templates/>
        </lexicog:usageExample>
    </xsl:template>

    <xsl:template match="tei:cit[@type = 'example' or @type = 'quote']/tei:quote">
        <xsl:variable name="workingLanguage" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        <rdf:value xml:lang="{$workingLanguage}">
            <xsl:apply-templates/>
        </rdf:value>
    </xsl:template>

    <xsl:template match="tei:quote/tei:mentioned | tei:def/tei:mentioned">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:etym">
        <lexinfo:etymology>
            <xsl:apply-templates/>
        </lexinfo:etymology>
    </xsl:template>

    <xsl:template match="tei:etym/*">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:etym/text()[normalize-space() = '']">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="tei:bibl">
        <dct:source>
            <xsl:apply-templates/>
        </dct:source>
    </xsl:template>

    <!-- cas de bibl dans etym -->

    <xsl:template match="tei:author">
        <dc:creator>
            <xsl:apply-templates/>
        </dc:creator>
    </xsl:template>


    <xsl:template match="tei:title">
        <dc:title>
            <xsl:apply-templates/>
        </dc:title>
    </xsl:template>

    <xsl:template match="tei:date">
        <dc:date>
            <xsl:apply-templates/>
        </dc:date>
    </xsl:template>

    <xsl:template match="tei:publisher">
        <dc:publisher>
            <xsl:apply-templates/>
        </dc:publisher>
    </xsl:template>

    <!-- Small annotation elements or intermediate text that disappear in Ontolex -->

    <xsl:template match="tei:emph">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Copy all template to account for possible missed elements -->
    <xsl:template match="@* | node()">
        <xsl:choose>
            <xsl:when test="name()">
                <xsl:message>
                    <xsl:value-of select="name()"/> - <xsl:value-of select="."/>
                </xsl:message>
            </xsl:when>
            <!--  <xsl:when test="attribute()">
                <xsl:message>
                    <xsl:value-of select="concat('@', name())"/>
                </xsl:message>
            </xsl:when>-->
        </xsl:choose>

        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
