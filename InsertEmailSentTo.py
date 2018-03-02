import pandas
import pymysql
import traceback
import datetime as dt

SEL_RAW_EMAIL = """select EmailID, AudienceSegment, EmailCampaignName, Fulldate,
                          EmailVersion, SubjectLineCode
                   from CP_Email_Final
                   group by EmailID, AudienceSegment, EmailCampaignName, Fulldate, EmailVersion, SubjectLineCode"""
SEL_EMAIL_CAMPAIGN = """SELECT id FROM EmailCampaign
                        WHERE CampaignName = %(campaignName)s AND DeploymentDate = %(date)s"""
SEL_AUDIENCE_ID = """SELECT id FROM Audience
                     WHERE Audience = %(audience)s"""
SEL_SUBJECT_ID = """SELECT id FROM SubjectLine
                     WHERE SubjectLine = %(subject)s"""
SEL_VERSION_ID = """SELECT id FROM Version
                     WHERE Version = %(version)s"""
SEL_LINK = """SELECT LinkID FROM Link
              WHERE EmailID = %(email)s
              AND LinkName = %(name)s
              AND LinkURL = %(url)s"""

SEL_SPECIFIC_RAW_EMAIL = """SELECT DISTINCT EmailEventType, EmailEventDateTime,
                                   HyperlinkName, EmailURL
                            FROM CP_Email_Final
                            where EmailID = %(address)s
                            and AudienceSegment = %(audience)s
                            and EmailCampaignName = %(campaign)s
                            and Fulldate = %(date)s
                            and EmailVersion = %(version)s
                            and SubjectLineCode = %(subject)s"""

INS_EMAIL_CAMPAIGN = """INSERT INTO EmailCampaign (CampaignName, DeploymentDate)
                        VALUES (%(campaignName)s, %(date)s)"""
INS_EMAIL = """INSERT INTO Email (EmailCampaignID)
               VALUES (%(campaign)s)"""
INS_AUDIENCE = """INSERT INTO Audience (Audience)
                  VALUES (%(audience)s)"""
INS_VERSION = """INSERT INTO Version (Version)
                  VALUES (%(version)s)"""
INS_SUBJECT = """INSERT INTO SubjectLine (SubjectLine)
                  VALUES (%(subject)s)"""
INS_EMAIL_AUDIENCE = """INSERT INTO EmailAudience (EmailID, AudienceID)
                        VALUES (%(email)s, %(audience)s)"""
INS_EMAIL_VERSION = """INSERT INTO EmailVersion (EmailID, VersionID)
                       VALUES (%(email)s, %(version)s)"""
INS_EMAIL_SUBJECT = """INSERT INTO EmailSubject (EmailID, SubjectLineID)
                       VALUES (%(email)s, %(subject)s)"""
INS_EMAIL_SENTTO = """INSERT INTO EmailSentTo (EmailID, emailAddressID)
                      VALUES (%(email)s, %(address)s)"""
INS_LINK = """INSERT INTO Link (LinkName, LinkURL, EmailID)
              VALUES (%(name)s, %(url)s, %(email)s)"""
INS_EMAIL_EVENT = """INSERT INTO EmailEvent (eventType, eventDate, EmailID, emailAddressID)
                     VALUES (%(type)s, %(date)s, %(email)s, %(address)s)"""


def sel_row_id(obj, query, cursor):
    try:
        cursor.execute(query, obj)
        row_id = cursor.fetchone()

        if row_id is None:
            return None
        else:
            return row_id[0]
    except:
        print("Error selecting row ID: ", (query % obj))
        print(traceback.format_exc())
        exit()


def insert_row(obj, query, cursor):
    try:
        cursor.execute(query, obj)
        return cursor.lastrowid
    except:
        print("Error inserting row: ", (query % obj))
        print(traceback.format_exc())
        exit()


def insert_emails(row, cursor):
    deployment_date = dt.datetime.strptime(row[3], '%m/%d/%Y')
    email_campaign = {'campaignName': row[2], 'date': deployment_date}
    campaign_id = sel_row_id(email_campaign, SEL_EMAIL_CAMPAIGN, cursor)

    email = {'campaign': campaign_id, 'address': row[0]}
    email['email'] = insert_row(email, INS_EMAIL, cursor)

    audience = {'audience': row[1]}
    if audience['audience'] != '':
        audience_id = sel_row_id(audience, SEL_AUDIENCE_ID, cursor)
        if audience_id is not None:
            email['audience'] = audience_id
            insert_row(email, INS_EMAIL_AUDIENCE, cursor)

    subject = {'subject': row[5]}
    if subject['subject'] != '':
        subject_id = sel_row_id(subject, SEL_SUBJECT_ID, cursor)
        if subject_id is not None:
            email['subject'] = subject_id
            insert_row(email, INS_EMAIL_SUBJECT, cursor)

    version = {'version': row[1]}
    if version['version'] != '':
        version_id = sel_row_id(version, SEL_VERSION_ID, cursor)
        if version_id is not None:
            email['version'] = version_id
            insert_row(email, INS_EMAIL_VERSION, cursor)

    insert_row(email, INS_EMAIL_SENTTO, cursor)

    return email['email']


def insert_email_event_links(email, cursor):
    cursor.execute(SEL_SPECIFIC_RAW_EMAIL, email)
    email_events = cursor.fetchall()

    for row in email_events:
        email_event = {'email': email['email'], 'type': row[0],
                       'date': dt.datetime.strptime(row[1], '%m/%d/%y %I:%M %p'),
                       'address': email['address']}
        link = {'name': row[2], 'url': row[3], 'email': email['email']}

        if link['name'] != '':
            link_id = sel_row_id(link, SEL_LINK, cursor)
            if link_id is None:
                link_id = insert_row(link, INS_LINK, cursor)
        else:
            link_id = None

        email_event['link'] = link_id
        insert_row(email_event, INS_EMAIL_EVENT, cursor)


def main():
    connection = pymysql.connect(host='hardworlder.com',
                                 user='',
                                 password='',
                                 db='cpe366',
                                 port=3306)

    with connection.cursor() as cursor:
        cursor.execute(SEL_RAW_EMAIL)
        raw_emails = cursor.fetchall()

        for row in raw_emails:
            email_id = insert_emails(row, cursor)

            email = {'email': email_id, 'address': row[0], 'audience': row[1], 'campaign': row[2],
                     'date': row[3], 'version': row[4], 'subject': row[5]}

            insert_email_event_links(email, cursor)
            connection.commit()

    connection.commit()
    connection.close()


if __name__ == '__main__':
    main()
