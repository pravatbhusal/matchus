# Generated by Django 3.1.2 on 2020-11-04 01:45

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('matchus', '0011_auto_20201104_0133'),
    ]

    operations = [
        migrations.RenameField(
            model_name='chat',
            old_name='sent',
            new_name='date',
        ),
    ]
