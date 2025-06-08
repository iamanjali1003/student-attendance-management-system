# ER Diagram

## Entity Relationship Diagram

### Complete ER Diagram (Mermaid)

```mermaid
erDiagram
    DEPARTMENTS {
        int department_id PK
        varchar department_name UK
        timestamp created_at
    }

    FACULTY {
        int faculty_id PK
        varchar name
        int department_id FK
        varchar email UK
        varchar phone
        timestamp created_at
    }

    STUDENTS {
        int student_id PK
        varchar name
        int department_id FK
        varchar email UK
        varchar roll_number UK
        varchar phone
        timestamp created_at
    }

    COURSES {
        int course_id PK
        varchar course_name
        varchar course_code UK
        int faculty_id FK
        int department_id FK
        int credits
        timestamp created_at
    }

    COURSE_ENROLLMENTS {
        int enrollment_id PK
        int student_id FK
        int course_id FK
        date enrollment_date
        enum status
    }

    ATTENDANCE {
        int attendance_id PK
        int student_id FK
        int course_id FK
        date date
        enum status
        int marked_by FK
        timestamp created_at
        timestamp updated_at
    }

    ATTENDANCE_LOG {
        int log_id PK
        int attendance_id
        int student_id
        int course_id
        date date
        enum old_status
        enum new_status
        enum action_type
        int changed_by
        timestamp changed_at
    }

    DEPARTMENTS ||--o{ FACULTY : "has"
    DEPARTMENTS ||--o{ STUDENTS : "belongs_to"
    DEPARTMENTS ||--o{ COURSES : "offers"
    FACULTY ||--o{ COURSES : "teaches"
    FACULTY ||--o{ ATTENDANCE : "marks"
    STUDENTS ||--o{ COURSE_ENROLLMENTS : "enrolls"
    COURSES ||--o{ COURSE_ENROLLMENTS : "has_enrollment"
    STUDENTS ||--o{ ATTENDANCE : "has_record"
    COURSES ||--o{ ATTENDANCE : "tracks"
    ATTENDANCE ||--o{ ATTENDANCE_LOG : "logs"
```

### Detailed Entity Relationship Flow

```mermaid
graph TD
    A[DEPARTMENTS<br/>department_id PK<br/>department_name UK<br/>created_at]

    B[FACULTY<br/>faculty_id PK<br/>name<br/>department_id FK<br/>email UK<br/>phone<br/>created_at]

    C[STUDENTS<br/>student_id PK<br/>name<br/>department_id FK<br/>email UK<br/>roll_number UK<br/>phone<br/>created_at]

    D[COURSES<br/>course_id PK<br/>course_name<br/>course_code UK<br/>faculty_id FK<br/>department_id FK<br/>credits<br/>created_at]

    E[COURSE_ENROLLMENTS<br/>enrollment_id PK<br/>student_id FK<br/>course_id FK<br/>enrollment_date<br/>status]

    F[ATTENDANCE<br/>attendance_id PK<br/>student_id FK<br/>course_id FK<br/>date<br/>status<br/>marked_by FK<br/>created_at<br/>updated_at]

    G[ATTENDANCE_LOG<br/>log_id PK<br/>attendance_id<br/>student_id<br/>course_id<br/>date<br/>old_status<br/>new_status<br/>action_type<br/>changed_by<br/>changed_at]

    A -->|1:M| B
    A -->|1:M| C
    A -->|1:M| D
    B -->|1:M| D
    B -->|1:M| F
    C -->|1:M| E
    D -->|1:M| E
    C -->|1:M| F
    D -->|1:M| F
    F -->|1:M| G

    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fce4ec
    style F fill:#f1f8e9
    style G fill:#fff8e1
```

### System Architecture Overview

```mermaid
flowchart LR
    subgraph "Core Entities"
        D[Departments]
        F[Faculty]
        S[Students]
        C[Courses]
    end

    subgraph "Junction Tables"
        CE[Course<br/>Enrollments]
    end

    subgraph "Transaction Tables"
        A[Attendance]
    end

    subgraph "Audit Tables"
        AL[Attendance<br/>Log]
    end

    D -.->|1:M| F
    D -.->|1:M| S
    D -.->|1:M| C
    F -.->|1:M| C
    F -.->|1:M| A

    S -.->|M:M| CE
    C -.->|M:M| CE

    S -.->|1:M| A
    C -.->|1:M| A

    A -.->|1:M| AL

    style D fill:#ffcdd2
    style F fill:#f8bbd9
    style S fill:#e1bee7
    style C fill:#d1c4e9
    style CE fill:#c5cae9
    style A fill:#bbdefb
    style AL fill:#b3e5fc
```

### Entities and Attributes

#### 1. **Departments**

- **department_id** (PK) - Primary Key
- department_name - Unique department name
- created_at - Timestamp

#### 2. **Faculty**

- **faculty_id** (PK) - Primary Key
- name - Faculty member name
- department_id (FK) - Foreign Key to Departments
- email - Unique email address
- phone - Contact number
- created_at - Timestamp

#### 3. **Students**

- **student_id** (PK) - Primary Key
- name - Student name
- department_id (FK) - Foreign Key to Departments
- email - Unique email address
- roll_number - Unique roll number
- phone - Contact number
- created_at - Timestamp

#### 4. **Courses**

- **course_id** (PK) - Primary Key
- course_name - Course name
- course_code - Unique course code
- faculty_id (FK) - Foreign Key to Faculty
- department_id (FK) - Foreign Key to Departments
- credits - Number of credits
- created_at - Timestamp

#### 5. **Course_Enrollments** (Junction Table)

- **enrollment_id** (PK) - Primary Key
- student_id (FK) - Foreign Key to Students
- course_id (FK) - Foreign Key to Courses
- enrollment_date - Date of enrollment
- status - Enrollment status (Active, Dropped, Completed)

#### 6. **Attendance**

- **attendance_id** (PK) - Primary Key
- student_id (FK) - Foreign Key to Students
- course_id (FK) - Foreign Key to Courses
- date - Attendance date
- status - Attendance status (Present, Absent, Late)
- marked_by (FK) - Foreign Key to Faculty
- created_at - Timestamp
- updated_at - Last update timestamp

#### 7. **Attendance_Log** (Audit Table)

- **log_id** (PK) - Primary Key
- attendance_id - Reference to Attendance
- student_id - Student reference
- course_id - Course reference
- date - Attendance date
- old_status - Previous status
- new_status - New status
- action_type - Type of action (INSERT, UPDATE, DELETE)
- changed_by - Who made the change
- changed_at - When the change occurred

## Relationships

### 1. **Department → Faculty** (One-to-Many)

- One department can have multiple faculty members
- Each faculty belongs to exactly one department
- **Relationship**: `Departments.department_id ← Faculty.department_id`

### 2. **Department → Students** (One-to-Many)

- One department can have multiple students
- Each student belongs to exactly one department
- **Relationship**: `Departments.department_id ← Students.department_id`

### 3. **Department → Courses** (One-to-Many)

- One department can offer multiple courses
- Each course belongs to exactly one department
- **Relationship**: `Departments.department_id ← Courses.department_id`

### 4. **Faculty → Courses** (One-to-Many)

- One faculty member can teach multiple courses
- Each course is taught by exactly one faculty member
- **Relationship**: `Faculty.faculty_id ← Courses.faculty_id`

### 5. **Students ↔ Courses** (Many-to-Many via Course_Enrollments)

- One student can enroll in multiple courses
- One course can have multiple students enrolled
- **Junction Table**: `Course_Enrollments`
- **Relationships**:
  - `Students.student_id ← Course_Enrollments.student_id`
  - `Courses.course_id ← Course_Enrollments.course_id`

### 6. **Students → Attendance** (One-to-Many)

- One student can have multiple attendance records
- Each attendance record belongs to exactly one student
- **Relationship**: `Students.student_id ← Attendance.student_id`

### 7. **Courses → Attendance** (One-to-Many)

- One course can have multiple attendance records
- Each attendance record belongs to exactly one course
- **Relationship**: `Courses.course_id ← Attendance.course_id`

### 8. **Faculty → Attendance** (One-to-Many)

- One faculty member can mark attendance for multiple records
- Each attendance record can be marked by one faculty member
- **Relationship**: `Faculty.faculty_id ← Attendance.marked_by`

### Data Flow and Process Diagram

```mermaid
graph TB
    subgraph "Data Flow Process"
        A1[Student Enrollment] --> A2[Course Assignment]
        A2 --> A3[Daily Attendance]
        A3 --> A4[Attendance Logging]
        A4 --> A5[Report Generation]
    end

    subgraph "Database Operations"
        B1[INSERT Student] --> B2[INSERT Enrollment]
        B2 --> B3[INSERT Attendance]
        B3 --> B4[TRIGGER Logging]
        B4 --> B5[SELECT Reports]
    end

    subgraph "User Roles"
        C1[Admin<br/>Manages Departments<br/>Faculty Students]
        C2[Faculty<br/>Marks Attendance<br/>Views Reports]
        C3[Student<br/>Views Own Attendance]
    end

    C1 --> B1
    C2 --> B3
    C3 --> B5

    style A1 fill:#e3f2fd
    style A2 fill:#e8f5e8
    style A3 fill:#fff3e0
    style A4 fill:#fce4ec
    style A5 fill:#f1f8e9

    style C1 fill:#ffebee
    style C2 fill:#e8f5e8
    style C3 fill:#e3f2fd
```

## Constraints

### Primary Key Constraints

- Each table has a unique primary key
- Auto-incrementing integer IDs for all entities

### Foreign Key Constraints

- All foreign keys reference valid primary keys
- CASCADE DELETE for maintaining referential integrity
- RESTRICT UPDATE to prevent orphaned records

### Unique Constraints

- `Students.email` - Unique email addresses
- `Students.roll_number` - Unique roll numbers
- `Faculty.email` - Unique faculty emails
- `Courses.course_code` - Unique course codes
- `Departments.department_name` - Unique department names

### Check Constraints

- `Courses.credits > 0` - Credits must be positive
- `Attendance.status` - Must be one of: Present, Absent, Late
- `Course_Enrollments.status` - Must be one of: Active, Dropped, Completed

### Not Null Constraints

- All primary keys
- Essential attributes like names, emails, dates

## Textual ER Diagram Representation

```
[Departments] 1----M [Faculty] 1----M [Courses]
     |                                   |
     |                                   |
     1                                   1
     |                                   |
     M                                   M
[Students] M----M [Course_Enrollments] M----1
     |
     |
     1
     |
     M
[Attendance] M----1 [Faculty]
     |
     |
     1
     |
     M
[Attendance_Log]
```

## Business Rules

1. **Department Rules**:

   - Each department must have a unique name
   - Departments can exist without faculty or students

2. **Faculty Rules**:

   - Faculty must belong to a department
   - Faculty can teach multiple courses
   - Faculty email must be unique

3. **Student Rules**:

   - Students must belong to a department
   - Student email and roll number must be unique
   - Students can enroll in multiple courses

4. **Course Rules**:

   - Courses must be assigned to a faculty and department
   - Course codes must be unique
   - Credits must be positive

5. **Enrollment Rules**:

   - Students can enroll in multiple courses
   - Enrollment status tracks student progress

6. **Attendance Rules**:

   - Attendance is tracked per student per course per date
   - Only one attendance record per student per course per date
   - Attendance can be marked by faculty
   - Status must be Present, Absent, or Late

7. **Audit Rules**:
   - All attendance changes are logged
   - Logs maintain history of modifications
   - Deletion logs are maintained for compliance
