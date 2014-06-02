'''
Created on Apr 11, 2014

@author: asseym
'''

from celery.task import Task, task
from celery.registry import tasks
from django.conf import settings
from rapidsms_httprouter.models import Message
from rapidsms.contrib.locations.models import Location
from poll.models import Poll
from .models import PollData, PollCategoryData
import operator

import logging

log = logging.getLogger(__name__)

@task
def export_poll_data():
    
    root = Location.tree.root_nodes()[0]
    for p in Poll.objects.order_by('-pk')[0:9]:
        print "[poll-export-task'] Starting to export poll [" + str(p.pk) + "] to GEOSERVER..."
        if p.categories.count():
            data = p.simple_responses_by_category(location=root)
            for loc, values in data.items():
                values_no_tatal = values.copy()
                del values_no_tatal['total']
                top_category_key = max(values_no_tatal.iteritems(), key=operator.itemgetter(1))[0]
                if p.is_yesno_poll():
                    pd, _ = PollData.objects.using('geoserver').get_or_create(\
                        district=loc.name,\
                        poll_id=p.pk,\
                        deployment_id=getattr(settings, 'DEPLOYMENT_ID', 1)
                    )
                    for k, v in values.items():
                        if k == 'total':
                            continue
                        if values['total'] > 0:
                            setattr(pd, k, (float(values[k]) / values['total']))
                        else:
                            setattr(pd, k, float(values[k]))
                    pd.save()
                else:
                    description = "<br/>".join(["%s: %0.1f%%" % (k,\
                                                                 (v * 100))\
                                                for k, v in values.items()])
                    pd, _ = PollCategoryData.objects.using('geoserver').get_or_create(\
                        district=loc.name,\
                        poll_id=p.pk,\
                        deployment_id=getattr(settings, 'DEPLOYMENT_ID', 1)
                    )
                    pd.description = description
                    pd.top_category = values[top_category_key]
                    pd.save()
            print "[poll-export-task'] End poll [" + str(p.pk) + "] export to GEOSERVER..."
        else:
            pass