#!/usr/bin/env python3

#from modules import *
import psycopg2

#####################################################
##  Database Connect
#####################################################

'''
Connects to the database using the connection string
'''
def openConnection():
# connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "y19s1c9120_mdin6872"
    passwd = "pwd"
    myHost = "soit-db-pro-2.ucc.usyd.edu.au"

    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)
    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    return conn

'''
List all the user associated issues in the database for a given user 
See assignment description for how to load user associated issues based on the user id (user_id)
'''
def findUserIssues(user_id):
    print(user_id)
    issue_db = []
    try:
        # fetch connection object to connect to the database
        conn = openConnection()
        # fetch cursor prepare to query the database

        curs = conn.cursor()
        curs.execute("BEGIN;")
        curs.callproc('listIssue', [int(user_id)])

        # loop through the resultset #/
        nr = 0
        row = curs.fetchone()

        while row is not None:
            nr+=1
            # convert to string for web display
            convert = list(map(str, row))
            issue_db.append(convert)
            row = curs.fetchone()
          
        if ( nr == 0 ):
            print("No entries found.")

    except psycopg2.Error as sqle:

        #TODO: add error handling #/
        print("psycopg2.Error : " + sqle.pgerror)

    issue = [{
        'title': row[0],
        'creator': row[1],
        'resolver': row[2],
        'verifier': row[3],
        'description': row[4],
        'issue_id': row[5]
    } for row in issue_db]

    curs.close()
    conn.close()
    return issue


'''
Find the associated issues for the user with the given userId (user_id) based on the searchString provided as the parameter, and based on the assignment description
'''
def findIssueBasedOnExpressionSearchedOnTitleAndDescription(searchString, user_id):

    # TODO - find necessary issues using sql database based on search input
    print(user_id)
    searchString = "%"+searchString+"%"
    print(searchString)
    
    issue_db = []

    try:
        # fetch connection object to connect to the database
        conn = openConnection()
        # fetch cursor prepare to query the database

        curs = conn.cursor()
        # execute a SQL query
        sql = """SELECT * FROM a3_issue WHERE (title LIKE %s or description LIKE %s) 
                 and (creator = %s or resolver = %s or verifier = %s) 
                 ORDER BY title ASC"""
        data = (searchString, searchString, user_id, user_id, user_id)
        curs.execute(sql, data)
        
        # can loop through the resultset
        print(curs)
        for result in curs:
            issue_db.append(list(result))
            
    except psycopg2.Error as sqle:       
        #TODO: add error handling #/
        print("psycopg2.Error : " + sqle.pgerror)

    issue = [{
        'title': row[0],
        'creator': row[1],
        'resolver': row[2],
        'verifier': row[3],
        'description': row[4],
        'issue_id': row[5]
    } for row in issue_db]

    curs.close()
    conn.close()
    return issue

#####################################################
##  Issue (new_issue, get all, get details)
#####################################################
#Add the details for a new issue to the database - details for new issue provided as parameters
def addIssue(title, creator, resolver, verifier, description):
    # TODO - add an issue
    # Insert a new issue to database
    # return False if adding was unsuccessful 
    # return Ture if adding was successful

    try:
        # fetch connection object to connect to the database
        conn = openConnection()
        # fetch cursor prepare to query the database

        curs = conn.cursor()

        sql = """INSERT INTO a3_issue (title, creator, resolver, verifier, description) VALUES (%s, %s, %s, %s, %s )"""
        data = (title, creator, resolver, verifier, description)

        curs.execute(sql, data)
        conn.commit()
    
    except psycopg2.Error as sqle:       
        #TODO: add error handling #/
        print("psycopg2.Error : " + sqle.pgerror)

        conn.rollback()
        return False

    curs.close()
    conn.close()
    return True

#Update the details of an issue having the provided issue_id with the values provided as parameters
def updateIssue(title, creator, resolver, verifier, description, issue_id):

    # TODO - update the issue using db

    # return False if adding was unsuccessful 
    # return Ture if adding was successful
     
    try:
        # fetch connection object to connect to the database
        conn = openConnection()
        # fetch cursor prepare to query the database
        curs = conn.cursor()

        sql = """UPDATE a3_issue SET title = %s, creator = %s, resolver= %s, verifier= %s, description=%s WHERE issue_id = %s """
        data = (title, creator, resolver, verifier, description, issue_id)

        curs.execute(sql, data)
        conn.commit()
    
    except psycopg2.Error as sqle:       
        #TODO: add error handling #/
        print("psycopg2.Error : " + sqle.pgerror)

        conn.rollback()
        return False

    curs.close()
    conn.close()

    return True
