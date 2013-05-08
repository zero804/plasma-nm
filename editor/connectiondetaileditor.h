/*
    Copyright 2013 Jan Grulich <jgrulich@redhat.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef PLASMA_NM_CONNECTION_DETAIL_EDITOR_H
#define PLASMA_NM_CONNECTION_DETAIL_EDITOR_H

#include <QtGui/QDialog>

#include <NetworkManagerQt/settings/ConnectionSettings>

namespace Ui
{
class ConnectionDetailEditor;
}

class ConnectionDetailEditor : public QDialog
{
    Q_OBJECT

public:
    explicit ConnectionDetailEditor(NetworkManager::Settings::ConnectionSettings::ConnectionType type,
                                    QWidget* parent = 0,
                                    const QString &vpnType = QString(),
                                    const QString &masterUuid = QString(),
                                    const QString &slaveType = QString(),
                                    Qt::WindowFlags f = 0);
    explicit ConnectionDetailEditor(const NetworkManager::Settings::ConnectionSettings::Ptr &setting,
                                    QWidget* parent = 0, Qt::WindowFlags f = 0);
    explicit ConnectionDetailEditor(NetworkManager::Settings::ConnectionSettings::ConnectionType type,
                                    const QVariantList &args,
                                    QWidget* parent = 0, Qt::WindowFlags f = 0);
    virtual ~ConnectionDetailEditor();

    bool isSlave() const { return !m_masterUuid.isEmpty() && !m_slaveType.isEmpty(); }

private Q_SLOTS:
    void connectionAddComplete(const QString & id, bool success, const QString & msg);
    void disconnectSignals();
    void gotSecrets(const QString & id, bool success, const NMVariantMapMap & secrets, const QString & msg);
    void saveSetting();
private:
    Ui::ConnectionDetailEditor * m_ui;
    NetworkManager::Settings::ConnectionSettings::Ptr m_connection;
    int m_numSecrets;
    bool m_new;
    QString m_vpnType;
    QString m_masterUuid;
    QString m_slaveType;

    void initEditor();
    void initTabs();
};

#endif // PLASMA_NM_CONNECTION_DETAIL_EDITOR_H
