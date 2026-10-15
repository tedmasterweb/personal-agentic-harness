# Data Processing Agreement

> **STATUS: DRAFT FOR LEGAL REVIEW — DO NOT USE AS-IS.**
>
> This is a working draft to hand to Spanish data protection counsel, not a finished contract. Having counsel review a draft costs roughly €800–1,500 versus €1,500–3,500 to draft from scratch — that saving is the point of this document.
>
> Every commitment here is deliberately matched to what the lean technical build in [07-minimum-viable-compliance.md](../07-minimum-viable-compliance.md) can actually deliver. **Do not let anyone "strengthen" a clause without checking you can still keep it.** An unmet contractual commitment is worse than a modest one.
>
> Items requiring counsel's decision are marked **[COUNSEL]**. Placeholders to complete are marked `[LIKE THIS]`.

---

## Data Processing Agreement

**Between:**

**(1)** `[CUSTOMER LEGAL NAME]`, `[ADDRESS]`, `[NIF/CIF]` — the **Controller**

**(2)** `[PROVIDER LEGAL NAME]`, `[ADDRESS]`, `[NIF/CIF]` — the **Processor**

each a "Party" and together the "Parties".

**Effective from:** `[DATE]`

This Agreement governs the Processor's processing of Personal Data on behalf of the Controller in connection with the services described in the Services Agreement between the Parties dated `[DATE]` (the "**Services**"). It forms part of, and is subject to, that Services Agreement.

---

### 1. Definitions

1.1 "**GDPR**" means Regulation (EU) 2016/679. "**LOPDGDD**" means Ley Orgánica 3/2018.

1.2 "**Personal Data**", "**Processing**", "**Controller**", "**Processor**", "**Sub-processor**", "**Data Subject**", "**Personal Data Breach**" and "**Supervisory Authority**" have the meanings given in the GDPR.

1.3 "**Customer Personal Data**" means Personal Data processed by the Processor on behalf of the Controller under this Agreement, as described in **Annex I**.

---

### 2. Roles and scope

2.1 The Controller determines the purposes and means of Processing. The Processor processes Customer Personal Data solely on the Controller's behalf.

2.2 The subject matter, duration, nature, purpose, types of Personal Data and categories of Data Subjects are set out in **Annex I**.

2.3 The Controller is responsible for ensuring it has a lawful basis for the Processing, for meeting its own transparency obligations to Data Subjects, and for the lawfulness of the instructions it gives.

---

### 3. Processing on instructions

3.1 The Processor shall process Customer Personal Data only on the Controller's documented instructions, including as to international transfers, unless required otherwise by Union or Member State law. Where such a legal requirement applies, the Processor shall inform the Controller before Processing unless that law prohibits it on important grounds of public interest.

3.2 This Agreement, the Services Agreement, and the Controller's use of the Services constitute the Controller's documented instructions.

3.3 The Processor shall immediately inform the Controller if, in its opinion, an instruction infringes the GDPR, the LOPDGDD, or other applicable data protection law.

3.4 **The Processor shall not use Customer Personal Data to train, fine-tune, or improve any machine learning model**, whether its own or a third party's, and shall not permit any Sub-processor to do so.

---

### 4. Confidentiality

4.1 The Processor shall ensure that any person authorised to process Customer Personal Data is subject to a binding obligation of confidentiality, and is made aware of the confidential and, where applicable, professionally privileged nature of the data.

4.2 The Processor acknowledges that Customer Personal Data may be subject to professional secrecy obligations binding the Controller, and that unauthorised disclosure may expose the Controller to consequences beyond data protection law.

4.3 As at the Effective Date, the persons authorised to access Customer Personal Data are limited to `[NAMED INDIVIDUAL(S)]`. The Processor shall notify the Controller of any change to this list.

> *Clause 4.3 is unusual and deliberate: as a sole operator, naming yourself is a stronger assurance than a generic "personnel" clause, and costs you nothing. Remove it if you take on staff.*

---

### 5. Security measures

5.1 The Processor shall implement appropriate technical and organisational measures to ensure a level of security appropriate to the risk, as required by Article 32 GDPR. The measures in place as at the Effective Date are set out in **Annex II**.

5.2 The Processor may update the measures in Annex II provided the level of security is not materially reduced. Material changes shall be notified to the Controller.

5.3 The Parties acknowledge that the measures reflect the state of the art, the costs of implementation, and the nature, scope, context and purposes of Processing, as contemplated by Article 32(1) GDPR.

---

### 6. Administrative access — break-glass

6.1 The Processor operates the Services on infrastructure it administers. The Processor shall access Customer Personal Data **only** where necessary to:

&nbsp;&nbsp;&nbsp;&nbsp;(a) respond to a support request made by the Controller;
&nbsp;&nbsp;&nbsp;&nbsp;(b) investigate or remediate a security incident or service failure; or
&nbsp;&nbsp;&nbsp;&nbsp;(c) comply with a legal obligation.

6.2 Any such access shall:

&nbsp;&nbsp;&nbsp;&nbsp;(a) be limited to what is necessary for the purpose;
&nbsp;&nbsp;&nbsp;&nbsp;(b) be **logged to storage the Processor cannot silently alter**; and
&nbsp;&nbsp;&nbsp;&nbsp;(c) **trigger an automated notification to the Controller**, save where notification would prejudice the investigation of an active security incident, in which case notification shall follow without undue delay thereafter.

6.3 The Controller may request the access log relating to its instance at any time, and the Processor shall provide it within `[10]` working days.

6.4 Where the Controller has elected to retain sole custody of its encryption passphrase (Annex II, item 1), the Processor cannot access Customer Personal Data at rest without the Controller's active participation.

> *Clause 6 is your commercial differentiator. It is also the clause a therapist's or lawyer's adviser will read first. Keep it specific — vagueness here loses deals.*

---

### 7. Sub-processors

7.1 The Controller grants the Processor **general authorisation** to engage Sub-processors, subject to this clause.

7.2 The Sub-processors engaged as at the Effective Date are listed in **Annex III**.

7.3 The Processor shall give the Controller at least **30 days'** notice before adding or replacing a Sub-processor. The Controller may object on reasonable data protection grounds within that period. If the Parties cannot resolve the objection, the Controller may terminate the Services without penalty, with a pro-rata refund of prepaid fees.

7.4 The Processor shall impose on each Sub-processor data protection obligations no less protective than those in this Agreement, and **remains fully liable to the Controller** for its Sub-processors' performance.

---

### 8. International transfers

8.1 Customer Personal Data is stored within the European Economic Area (Germany).

8.2 **Model inference is performed by a Sub-processor located in the United States**, as identified in Annex III. That transfer is made pursuant to the Standard Contractual Clauses adopted by Commission Implementing Decision (EU) 2021/914. **[COUNSEL — confirm the correct Module applies where the Processor engages a US Sub-processor; the Sub-processor's published DPA incorporates Module Two, whereas Module Three may be required. See 02-gdpr-obligations.md §2.]**

8.3 The Processor has carried out a transfer impact assessment in respect of the transfer at 8.2 and shall make it available to the Controller on request.

8.4 The Processor shall notify the Controller without undue delay if it becomes unable to comply with the transfer safeguards, and the Parties shall discuss remediation in good faith.

---

### 9. Assistance to the Controller

9.1 **Data Subject requests.** The Processor shall, taking into account the nature of the Processing, assist the Controller by appropriate technical and organisational measures in responding to requests under Articles 15–22 GDPR. Specifically, the Processor shall provide tooling to **export** and **erase** a Data Subject's Personal Data from the Controller's instance, and shall action a written request within `[10]` working days.

9.2 The Processor shall promptly forward to the Controller any request it receives directly from a Data Subject, and shall not respond to it itself except to confirm referral to the Controller.

9.3 **Article 32–36 assistance.** The Processor shall assist the Controller in ensuring compliance with its obligations regarding security, breach notification, data protection impact assessments and prior consultation, taking into account the nature of Processing and the information available to the Processor.

9.4 The Processor shall make available to the Controller a template data protection impact assessment covering the Services. **The Controller remains responsible for conducting and documenting its own assessment.**

---

### 10. Personal Data Breach

10.1 The Processor shall notify the Controller **without undue delay and in any event within 48 hours** of becoming aware of a Personal Data Breach affecting Customer Personal Data.

10.2 The notification shall include, to the extent known: the nature of the breach, the categories and approximate number of Data Subjects and records concerned, the likely consequences, the measures taken or proposed, and a contact point. Where information is not available at the time of notification, it shall be provided in phases without undue delay.

10.3 The Processor shall cooperate with the Controller and take reasonable steps to assist in the investigation, mitigation and remediation of the breach, including assisting the Controller with any notification to the Supervisory Authority or Data Subjects.

10.4 The Processor shall document all Personal Data Breaches affecting Customer Personal Data.

> *48 hours, not 24. Doc 07 recommends starting here and tightening once detection is proven in production. Do not commit to 24 until the monitoring in Annex II is running reliably — and consider tightening it later as a contract improvement you can offer at renewal.*

---

### 11. Deletion and return

11.1 On termination or expiry of the Services, the Processor shall, at the Controller's election, delete or return all Customer Personal Data, and delete existing copies, within **30 days**, unless retention is required by Union or Member State law.

11.2 The Controller may export its data at any time during the term, and during a **30-day** period following termination, after which deletion proceeds automatically.

11.3 The Processor shall issue a **written certificate of deletion** confirming completion.

11.4 Deletion extends to the Controller's instance, its encrypted storage volume, and backups, subject to backup rotation cycles not exceeding `[35]` days.

> *11.4 matters technically: backup rotation means "deleted" isn't instantaneous. State the real cycle rather than promising immediacy you can't deliver.*

---

### 12. Audit

12.1 The Processor shall make available to the Controller all information necessary to demonstrate compliance with Article 28 GDPR.

12.2 The Processor shall satisfy its obligations under Article 28(3)(h) in the first instance by providing: this Agreement, Annex II, its record of processing activities so far as it relates to the Controller, access logs under clause 6.3, and any third-party certifications or reports it or its Sub-processors hold.

12.3 Where the information provided under 12.2 is not sufficient, the Controller may conduct or mandate an audit, on **30 days'** written notice, no more than **once per calendar year** (save following a Personal Data Breach), during business hours, subject to confidentiality undertakings, and **at the Controller's cost**.

> *12.2 is where an ISO 27001 certificate would eventually do a lot of work — one certificate satisfies every customer's audit right at once. Until then, documentation-first is the proportionate position for a sole operator.*

---

### 13. Liability

13.1 **[COUNSEL — liability position to be determined. Note the mismatch flagged in 04-customer-documents.md §2: a cap set at 12 months' fees may be commercially unrealistic against a privileged-data breach, and any sophisticated Controller will negotiate it. Confirm interaction with the Services Agreement cap, whether GDPR administrative fines are insurable in Spain, and alignment with the cyber liability policy limits.]**

13.2 Nothing in this Agreement limits either Party's liability where such limitation is not permitted by applicable law.

---

### 14. General

14.1 This Agreement takes precedence over the Services Agreement in the event of conflict, in respect of data protection matters.

14.2 This Agreement is governed by the laws of Spain. The Parties submit to the exclusive jurisdiction of the courts of `[SANTA CRUZ DE TENERIFE / LAS PALMAS]`. **[COUNSEL — confirm.]**

14.3 If any provision is held invalid, the remainder continues in effect.

14.4 Amendments must be in writing and signed by both Parties, save for updates to Annexes II and III made in accordance with clauses 5.2 and 7.3.

**Signed:**

| Controller | Processor |
|---|---|
| Name: | Name: |
| Position: | Position: |
| Date: | Date: |

---

## Annex I — Details of Processing

**Subject matter:** Provision of a hosted AI assistant accessible via the Signal messaging application.

**Duration:** The term of the Services Agreement, plus the deletion period in clause 11.

**Nature and purpose:** Hosting, storage, transmission and processing of messages and attachments exchanged between the Controller's authorised users and the AI assistant, including transmission to a third-party model inference provider for the purpose of generating responses.

**Types of Personal Data:**

- Message content submitted by the Controller's authorised users, which **may contain any category of data the user chooses to submit**, including special category data under Article 9 GDPR
- Attachments (documents, images) submitted by users
- Telephone numbers of authorised users
- Assistant-generated memory and session records derived from the above
- Technical logs, including timestamps and access records

**Categories of Data Subjects:**

- The Controller's authorised users (e.g. practitioners, staff)
- **Third parties whose Personal Data the Controller's users choose to include in messages** — which may include the Controller's own clients or patients

**Special categories:** The Controller determines what is submitted. Where the Controller is a healthcare or legal professional, submitted data may include health data (Art. 9) and/or data subject to professional secrecy. The Controller is responsible for ensuring an appropriate Article 9 condition applies.

> *This Annex is deliberately blunt about the fact that users can paste anything. It protects you by making the Controller's responsibility explicit, and it is honest — which matters more with this customer segment than sounding reassuring.*

---

## Annex II — Technical and Organisational Measures

Measures in place as at the Effective Date.

**1. Encryption at rest.** Customer data is stored on a LUKS-encrypted volume. Passphrase custody is by Controller election:

&nbsp;&nbsp;&nbsp;&nbsp;☐ **Option A** — Controller sole custody. The Processor cannot decrypt without the Controller's participation.
&nbsp;&nbsp;&nbsp;&nbsp;☐ **Option B** — Controller custody with sealed escrow held by the Processor, accessible only via the break-glass procedure in clause 6, which notifies the Controller.

*Selected: `[A / B]`*

**2. Encryption in transit.** TLS for all external connections. Messages between end users and the Service are end-to-end encrypted by the Signal protocol.

**3. Tenant isolation.** Each Controller's instance runs on a **dedicated virtual server** with dedicated storage. No compute, storage, or database is shared between Controllers.

**4. Access control.** SSH key-based authentication only; password authentication disabled. Network-level firewall restricting inbound traffic. Administrative credentials held in a dedicated secrets manager with per-Controller scoping and documented rotation on offboarding.

**5. Logging and monitoring.** Administrative access, authentication events, privilege escalation and encryption-key access are logged and shipped to separate infrastructure under distinct credentials. Automated alerting on interactive login to a Controller instance and on escrow access.

**6. Backups.** Encrypted nightly backups with a `[30]`-day retention cycle. Restore testing performed quarterly and recorded.

**7. Assistant capability restriction.** For Controllers in regulated professions, the assistant is provisioned **without shell, code execution, or host file access** by default, materially limiting the impact of prompt injection via untrusted content. Enabling these requires the Controller's written request.

**8. Data location.** Hosting and storage in Germany (Nuremberg / Falkenstein). Model inference in the United States — see Annex III.

**9. Patching.** Security updates applied automatically; a documented monthly review covers the application and its dependencies.

**10. Personnel.** Sole operator as at the Effective Date. Confidentiality obligation per clause 4.

**11. Deletion.** Tooling to export and erase individual Data Subject records, including assistant memory files and session history. Instance decommissioning destroys the server and its encrypted volume.

**12. Business continuity.** Documented recovery runbook. **[Note: the Processor is a sole operator. Availability commitments are set out in the Services Agreement, not this Annex.]**

---

## Annex III — Sub-processors

| Sub-processor | Purpose | Location | Safeguard |
|---|---|---|---|
| **Hetzner Online GmbH** | Hosting, storage, backups | Germany (Nuremberg / Falkenstein) | EEA — no transfer mechanism required. ISO/IEC 27001:2022 certified; BSI C5 Type 2 |
| **Fireworks AI, Inc.** | AI model inference | United States | SCCs per Commission Implementing Decision (EU) 2021/914. SOC 2 Type II. Operates zero-retention for the models used — data held in volatile memory for the duration of the request only |
| `[eSIM / NUMBER PROVIDER]` | Provisioning of the telephone number used for Service registration | `[TBD]` | `[TBD]` |

**Note on Signal.** Messages are transmitted via the Signal service. Message content is end-to-end encrypted and is not accessible to the Signal Foundation. **[COUNSEL — confirm whether Signal should be listed as a Sub-processor given it cannot access content but does process metadata.]**

The current list is maintained at `[URL]`. Changes are notified per clause 7.3.

---

# Companion note: briefing your counsel

Hand this draft over with the following. It keeps the engagement short and therefore cheap.

**Ask them to resolve, specifically:**

1. **Clause 8.2 — SCC Module.** Fireworks' published DPA incorporates Module Two (controller→processor). As a processor engaging them as a sub-processor, Module Three would ordinarily apply. Is the chain valid as-is, and if not, what's the fix?
2. **Clause 13 — liability.** Cap position, interaction with the Services Agreement, insurability of GDPR fines in Spain, alignment with the cyber policy.
3. **Clause 14.2 — jurisdiction.**
4. **Annex III — Signal's status** given end-to-end encryption.
5. **Whether any Spanish professional-secrecy rules restrict *abogados* or healthcare professionals from using third-party processors for privileged material at all.** *This is the question that determines whether the target market exists — ask it first.*
6. **The DPO determination** from [07](../07-minimum-viable-compliance.md) §5 — bundle it into the same engagement.

**Tell them explicitly:**

> This is a sole-operator startup. I need a document I can actually comply with, not a best-practice template. Please flag any clause where the commitment exceeds what a one-person business can realistically deliver, and tell me the minimum that is legally sufficient rather than the market standard.

That instruction is worth stating plainly — otherwise you will get a document drafted for a company with a compliance team, and every clause you cannot meet is a liability rather than a protection.
